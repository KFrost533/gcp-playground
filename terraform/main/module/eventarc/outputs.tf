output "service" {
  description = "Enabled Eventarc service."
  value       = google_project_service.eventarc.service
}
