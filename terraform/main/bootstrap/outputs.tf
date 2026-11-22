output "project_id" {
  description = "GCP project ID."
  value       = nonsensitive(data.google_secret_manager_secret_version.gcp_account_id.secret_data)
}

output "project_name" {
  description = "GCP project display name."
  value       = nonsensitive(data.google_secret_manager_secret_version.gcp_account_name.secret_data)
}

output "gcp_billing_account" {
  description = "Existing billing account associated with the target project."
  value       = data.google_secret_manager_secret_version.gcp_billing_account.secret_data
  sensitive   = true
}

output "gcp_secret_id_account" {
  description = "GCP Account ID containing secrets data for the project"
  value       = var.gcp_secret_project_id
}

output "youtube_output_bucket" {
  description = "Cloud Storage bucket containing the YouTube search CSV files."
  value       = module.cloudstorage.youtube_output_bucket
}

output "youtube_scheduler_job_name" {
  description = "Cloud Scheduler job that triggers the YouTube export."
  value       = module.cloudscheduler.job_name
}