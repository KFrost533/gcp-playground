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