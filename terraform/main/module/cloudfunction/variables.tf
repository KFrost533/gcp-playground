variable "project_id" {
  description = "GCP project ID where the function is deployed."
  type        = string
}

variable "secret_project_id" {
  description = "GCP project ID containing the SMTP Secret Manager secret."
  type        = string
}

variable "location" {
  description = "Cloud Functions region."
  type        = string
}

variable "function_name" {
  description = "Second-generation Cloud Function name."
  type        = string
  default     = "storage-upload-notifier"
}

variable "notification_email" {
  description = "Recipient for upload notifications."
  type        = string
}

variable "bucket_name" {
  description = "Cloud Storage bucket whose finalized events invoke the function."
  type        = string
}

variable "function_source_bucket" {
  description = "Bucket containing the Cloud Function source archive."
  type        = string
}

variable "function_source_object" {
  description = "Object containing the Cloud Function source archive."
  type        = string
}

variable "eventarc_service_account_email" {
  description = "Service account email used by the Eventarc trigger."
  type        = string
}

variable "smtp_secret_name" {
  description = "Secret Manager secret containing Gmail address and app password JSON."
  type        = string
  default     = "smtp_config"
}

variable "service_account_id" {
  description = "Runtime service account ID for the Cloud Function."
  type        = string
  default     = "storage-upload-notifier"
}
