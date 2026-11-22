output "function_name" {
  description = "Name of the deployed Cloud Function."
  value       = google_cloudfunctions2_function.storage_notification.name
}

output "youtube_function_name" {
  description = "Name of the YouTube summary Cloud Function."
  value       = google_cloudfunctions2_function.youtube_data_summary.name
}

output "youtube_function_uri" {
  description = "URI of the YouTube summary Cloud Function."
  value       = google_cloudfunctions2_function.youtube_data_summary.service_config[0].uri
}

output "youtube_service_account_email" {
  description = "Service account email used to invoke the YouTube function."
  value       = google_service_account.function.email
}