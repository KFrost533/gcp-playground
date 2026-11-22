resource "google_project_service" "services" {
  for_each = toset([
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudscheduler.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "youtube.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_on_destroy = false
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

data "google_secret_manager_secret_version" "youtube_api_key" {
  project = var.secret_project_id
  secret  = var.youtube_api_key_secret_name
}

resource "google_project_iam_member" "youtube_secret_accessor" {
  project = var.secret_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.function.email}"
}

resource "google_storage_bucket_iam_member" "youtube_output_writer" {
  bucket = var.youtube_output_bucket
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.function.email}"
}

resource "google_project_iam_member" "scheduler_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.function.email}"
}

resource "google_cloudfunctions2_function" "storage_notification" {
  project  = var.project_id
  name     = var.storage_upload_notification_function_name
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

resource "google_cloudfunctions2_function" "youtube_data_summary" {
  project  = var.project_id
  name     = var.youtube_data_function_function_name
  location = var.location

  build_config {
    runtime     = "python312"
    entry_point = "youtube_data_summary"

    source {
      storage_source {
        bucket = var.youtube_function_source_bucket
        object = var.youtube_function_source_object
      }
    }
  }

  service_config {
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.function.email

    environment_variables = {
      YOUTUBE_OUTPUT_BUCKET = var.youtube_output_bucket
      YOUTUBE_RESULT_LIMIT  = tostring(var.youtube_result_limit)
      YOUTUBE_SEARCH_TERMS  = join(",", var.youtube_search_terms)
    }

    secret_environment_variables {
      key        = "YOUTUBE_API_KEY"
      project_id = var.secret_project_id
      secret     = var.youtube_api_key_secret_name
      version    = "latest"
    }
  }

  labels = {
    project = "youtube-data-summary"
  }

  depends_on = [
    google_project_service.services,
    google_project_iam_member.youtube_secret_accessor,
    google_storage_bucket_iam_member.youtube_output_writer,
    google_project_iam_member.scheduler_invoker,
    data.google_secret_manager_secret_version.youtube_api_key
  ]
}
