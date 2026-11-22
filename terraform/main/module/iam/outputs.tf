output "iam_role_arn" {
  value = google_project_iam_member.eventarc_receiver.role
}

output "iam_role_name" {
  value = google_project_iam_member.function_invoker.role
}

output "iam_member" {
  value = google_project_iam_member.storage_pubsub_publisher.member
}

output "service_account_email" {
  description = "Service account email used by Eventarc."
  value       = google_service_account.eventarc.email
}