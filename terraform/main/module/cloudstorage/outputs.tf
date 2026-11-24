output "bucket_name" {
  description = "Name of the Cloud Storage bucket."
  value       = google_storage_bucket.this.name
}

output "bucket_url" {
  description = "gs:// URL of the Cloud Storage bucket."
  value       = "gs://${google_storage_bucket.this.name}"
}

output "function_source_bucket" {
  description = "Bucket containing the Cloud Function source archive."
  value       = google_storage_bucket.source.name
}

output "function_source_object" {
  description = "Object containing the Cloud Function source archive."
  value       = google_storage_bucket_object.source.name
}

output "youtube_function_source_object" {
  description = "Object containing the YouTube Cloud Function source archive."
  value       = google_storage_bucket_object.youtube_data.name
}

output "youtube_output_bucket" {
  description = "Bucket containing exported YouTube search CSV files."
  value       = google_storage_bucket.youtube_summary_data_storage.name
}

output "youtube_config_object" {
  description = "Object containing the editable YouTube search configuration."
  value       = google_storage_bucket_object.youtube_search_config.name
}