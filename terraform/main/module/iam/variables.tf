variable "project_id" {
  description = "GCP project ID receiving Eventarc IAM configuration."
  type        = string
}

variable "service_account_id" {
  description = "Service account ID used by Eventarc."
  type        = string
  default     = "eventarc-storage-trigger"
}
