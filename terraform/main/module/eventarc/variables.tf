variable "project_id" {
  description = "GCP project ID containing the bucket and Cloud Function."
  type        = string
}

variable "location" {
  description = "Eventarc trigger location; use the Cloud Storage bucket location."
  type        = string
}

variable "bucket_name" {
  description = "Cloud Storage bucket that publishes upload completion events."
  type        = string
}

variable "cloud_function_name" {
  description = "Existing second-generation Cloud Function receiving the storage event."
  type        = string
}

variable "trigger_name" {
  description = "Eventarc trigger name."
  type        = string
  default     = "storage-upload"
}

variable "service_account_id" {
  description = "Service account ID used by Eventarc."
  type        = string
  default     = "eventarc-storage-trigger"
}