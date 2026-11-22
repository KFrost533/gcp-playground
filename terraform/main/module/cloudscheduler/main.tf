resource "google_project_service" "cloud_scheduler" {
  project = var.project_id
  service = "cloudscheduler.googleapis.com"

  disable_on_destroy = false
}

resource "google_cloud_scheduler_job" "youtube_data_summary" {
  project   = var.project_id
  name      = var.job_name
  region    = var.location
  schedule  = var.schedule
  time_zone = var.timezone

  http_target {
    http_method = "POST"
    uri         = var.function_uri

    oidc_token {
      service_account_email = var.service_account_email
    }
  }

  depends_on = [google_project_service.cloud_scheduler]
}
