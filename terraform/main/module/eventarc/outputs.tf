output "trigger_name" {
  description = "Name of the Cloud Storage Eventarc trigger."
  value       = google_eventarc_trigger.storage_finalize.name
}

output "service_account_email" {
  description = "Service account used to deliver Eventarc events."
  value       = google_service_account.eventarc.email
}