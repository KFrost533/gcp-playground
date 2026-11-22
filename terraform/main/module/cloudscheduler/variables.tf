variable "project_id" {
  description = "GCP project ID where the scheduler job is created."
  type        = string
}

variable "location" {
  description = "Cloud Scheduler region."
  type        = string
}

variable "job_name" {
  description = "Cloud Scheduler job name."
  type        = string
}

variable "function_uri" {
  description = "Cloud Function HTTP URI invoked by the scheduler."
  type        = string
}

variable "service_account_email" {
  description = "Service account used for the OIDC token."
  type        = string
}

variable "schedule" {
  description = "Cloud Scheduler cron expression."
  type        = string
  default     = "0 9 * * *"
}

variable "timezone" {
  description = "IANA time zone used for the schedule."
  type        = string
  default     = "Asia/Tokyo"
}
