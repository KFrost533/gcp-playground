import json
import os
import smtplib
import ssl
from email.message import EmailMessage

import functions_framework


@functions_framework.cloud_event
def storage_changed(cloud_event):
    config = json.loads(os.environ["SMTP_CONFIG"])
    data = cloud_event.data or {}
    bucket = data.get("bucket", "unknown-bucket")
    name = data.get("name", "unknown-object")
    event_type = cloud_event["type"]

    message = EmailMessage()
    message["From"] = config["gmail_address"]
    message["To"] = os.environ["NOTIFICATION_TO"]

    if event_type == "google.cloud.storage.object.v1.finalized":
        size = data.get("size", "unknown")
        message["Subject"] = f"GCS upload: {name}"
        message.set_content(
            f"Cloud Storage upload completed.\n\n"
            f"Bucket: {bucket}\n"
            f"Object: {name}\n"
            f"Size: {size} bytes\n"
            f"URI: gs://{bucket}/{name}\n"
        )
    elif event_type == "google.cloud.storage.object.v1.deleted":
        message["Subject"] = f"GCS deletion: {name}"
        message.set_content(
            f"Cloud Storage object deleted.\n\n"
            f"Bucket: {bucket}\n"
            f"Object: {name}\n"
            f"URI: gs://{bucket}/{name}\n"
        )
    else:
        raise ValueError(f"Unsupported Cloud Storage event type: {event_type}")

    context = ssl.create_default_context()
    with smtplib.SMTP("smtp.gmail.com", 587, timeout=20) as smtp:
        smtp.starttls(context=context)
        smtp.login(config["gmail_address"], config["app_password"])
        smtp.send_message(message)

