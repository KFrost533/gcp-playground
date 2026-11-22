resource "google_project_service" "eventarc" {
  project = var.project_id
  service = "eventarc.googleapis.com"
}

output "enabled" {
  description = "Indicates that the Eventarc API is enabled."
  value       = google_project_service.eventarc.service
}