import csv
import io
import json
import os
from datetime import datetime, timezone
from urllib.parse import urlencode
from urllib.request import urlopen

import functions_framework
from google.cloud import storage


YOUTUBE_SEARCH_URL = "https://www.googleapis.com/youtube/v3/search"
CSV_FIELDS = [
    "searched_at",
    "search_term",
    "rank",
    "video_id",
    "title",
    "description",
    "channel_id",
    "channel_title",
    "published_at",
    "thumbnail_url",
    "video_url",
]


def _required_environment(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def _search_terms() -> list[str]:
    terms = [
        term.strip()
        for term in _required_environment("YOUTUBE_SEARCH_TERMS").split(",")
        if term.strip()
    ]
    if not terms:
        raise RuntimeError("YOUTUBE_SEARCH_TERMS must contain at least one term")
    return terms


def _search_youtube(api_key: str, term: str, limit: int) -> list[dict]:
    query = urlencode(
        {
            "part": "snippet",
            "q": term,
            "type": "video",
            "maxResults": limit,
            "key": api_key,
        }
    )
    with urlopen(f"{YOUTUBE_SEARCH_URL}?{query}", timeout=30) as response:
        payload = json.load(response)
    return payload.get("items", [])


def _to_csv_rows(term: str, items: list[dict], searched_at: str) -> list[dict]:
    rows = []
    for rank, item in enumerate(items, start=1):
        video_id = item.get("id", {}).get("videoId", "")
        snippet = item.get("snippet", {})
        thumbnails = snippet.get("thumbnails", {})
        thumbnail_url = (
            thumbnails.get("high")
            or thumbnails.get("medium")
            or thumbnails.get("default")
            or {}
        ).get("url", "")
        rows.append(
            {
                "searched_at": searched_at,
                "search_term": term,
                "rank": rank,
                "video_id": video_id,
                "title": snippet.get("title", ""),
                "description": snippet.get("description", ""),
                "channel_id": snippet.get("channelId", ""),
                "channel_title": snippet.get("channelTitle", ""),
                "published_at": snippet.get("publishedAt", ""),
                "thumbnail_url": thumbnail_url,
                "video_url": f"https://www.youtube.com/watch?v={video_id}",
            }
        )
    return rows


def _build_csv(rows: list[dict]) -> str:
    output = io.StringIO(newline="")
    writer = csv.DictWriter(output, fieldnames=CSV_FIELDS)
    writer.writeheader()
    writer.writerows(rows)
    return output.getvalue()


@functions_framework.http
def youtube_data_summary(_request):
    api_key = _required_environment("YOUTUBE_API_KEY")
    bucket_name = _required_environment("YOUTUBE_OUTPUT_BUCKET")
    result_limit = int(os.environ.get("YOUTUBE_RESULT_LIMIT", "10"))
    if not 1 <= result_limit <= 50:
        raise ValueError("YOUTUBE_RESULT_LIMIT must be between 1 and 50")

    now = datetime.now(timezone.utc)
    searched_at = now.isoformat()
    rows = []
    for term in _search_terms():
        items = _search_youtube(api_key, term, result_limit)
        rows.extend(_to_csv_rows(term, items, searched_at))

    object_name = f"youtube-search/{now:%Y/%m/%d}/youtube-results-{now:%Y%m%dT%H%M%SZ}.csv"
    storage_client = storage.Client()
    storage_client.bucket(bucket_name).blob(object_name).upload_from_string(
        _build_csv(rows),
        content_type="text/csv; charset=utf-8",
    )

    response = {
        "bucket": bucket_name,
        "object": object_name,
        "result_count": len(rows),
        "uri": f"gs://{bucket_name}/{object_name}",
    }
    return response, 200