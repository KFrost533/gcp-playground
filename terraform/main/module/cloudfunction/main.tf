resource "google_project_service" "services" {
  for_each = toset([
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com"
  ])

  project = var.project_id
  service = each.value
}

resource "google_service_account" "function" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Storage upload notification function"
}

resource "google_project_iam_member" "secret_accessor" {
  project = var.secret_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.function.email}"
}

data "google_secret_manager_secret_version" "smtp_config" {
  project = var.secret_project_id
  secret  = var.smtp_secret_name
}

resource "google_cloudfunctions2_function" "storage_notification" {
  project  = var.project_id
  name     = var.function_name
  location = var.location

  build_config {
    runtime     = "python312"
    entry_point = "storage_uploaded"

    source {
      storage_source {
        bucket = var.function_source_bucket
        object = var.function_source_object
      }
    }
  }

  service_config {
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.function.email

    environment_variables = {
      NOTIFICATION_TO = var.notification_email
    }

    secret_environment_variables {
      key        = "SMTP_CONFIG"
      project_id = var.secret_project_id
      secret     = var.smtp_secret_name
      version    = "latest"
    }
  }

  event_trigger {
    trigger_region        = var.location
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = var.eventarc_service_account_email

    event_filters {
      attribute = "bucket"
      value     = var.bucket_name
    }
  }

  labels = {
    project = "storage-upload-notifier"
  }

  depends_on = [
    google_project_service.services,
    google_project_iam_member.secret_accessor,
    data.google_secret_manager_secret_version.smtp_config
  ]
}