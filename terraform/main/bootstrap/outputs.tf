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