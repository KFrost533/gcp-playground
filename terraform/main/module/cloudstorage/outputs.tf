output "bucket_name" {
  description = "Name of the Cloud Storage bucket."
  value       = google_storage_bucket.this.name
}

output "bucket_url" {
  description = "gs:// URL of the Cloud Storage bucket."
  value       = "gs://${google_storage_bucket.this.name}"
}