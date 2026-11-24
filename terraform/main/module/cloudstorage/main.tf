resource "google_storage_bucket" "this" {
  project                     = var.project_id
  name                        = "${var.project_id}-event-notification"
  location                    = var.location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }

    action {
      type = "Delete"
    }
  }

  labels = {
    for_learning = "true"
    project      = lower(replace(var.project_name, " ", "-"))
    managed_by   = "terraform"
  }
}

// cloud function source bucket
resource "google_storage_bucket" "source" {
  project                     = var.project_id
  name                        = "${var.project_id}-cloudfunction-source"
  location                    = var.location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
  labels = {
    project    = lower(replace(var.project_name, " ", "-"))
    managed_by = "terraform"
  }
}

data "archive_file" "storage_notification_function_source" {
  type        = "zip"
  source_dir  = var.storage_notification_function_source_dir
  output_path = "cloudfunction/src/zip/storage-notification-function.zip"
}

resource "google_storage_bucket_object" "source" {
  name   = "storage-notification-${data.archive_file.storage_notification_function_source.output_md5}.zip"
  bucket = google_storage_bucket.source.name
  source = data.archive_file.storage_notification_function_source.output_path
}

// YouTube data summary function object
data "archive_file" "youtube_data_summary_function_source" {
  type        = "zip"
  source_dir  = var.youtube_data_function_source_dir
  output_path = "../cloudfunction/src/zip/youtube-data-summary-function.zip"
}

resource "google_storage_bucket_object" "youtube_data" {
  name   = "yt-data-summary-${data.archive_file.youtube_data_summary_function_source.output_md5}.zip"
  bucket = google_storage_bucket.source.name
  source = data.archive_file.youtube_data_summary_function_source.output_path
}

// bucket to store YouTube summary data
resource "google_storage_bucket" "youtube_summary_data_storage" {
  project                     = var.project_id
  name                        = "${var.project_id}-youtube-summary-storage"
  location                    = var.location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age            = 30
      matches_prefix = ["youtube-search/"]
    }

    action {
      type = "Delete"
    }
  }

  labels = {
    for_learning = "true"
    project      = lower(replace(var.project_name, " ", "-"))
    managed_by   = "terraform"
  }
}

// upload YouTube search configuration to use for the data summary function
resource "google_storage_bucket_object" "youtube_search_config" {
  name   = "config/youtube-search.json"
  bucket = google_storage_bucket.youtube_summary_data_storage.name
  content = jsonencode({
    search_terms = ["GCP Cloud Run"]
    result_limit = 10
  })
  content_type = "application/json"

  lifecycle {
    ignore_changes = [content, content_type]
  }
}