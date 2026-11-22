resource "google_cloud_scheduler_job" "youtube_data_summary" {
  project   = var.project_id
  name      = "${var.youtube_data_function_function_name}-daily"
  region    = var.location
  schedule  = var.youtube_schedule
  time_zone = var.youtube_schedule_timezone

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions2_function.youtube_data_summary.service_config[0].uri

    oidc_token {
      service_account_email = google_service_account.function.email
    }
  }

  depends_on = [
    google_project_service.services,
    google_cloudfunctions2_function.youtube_data_summary
  ]
}