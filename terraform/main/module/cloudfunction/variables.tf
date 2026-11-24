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

variable "storage_upload_notification_function_name" {
  description = "Storage upload notification Cloud Function name."
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

variable "cloudfunction_source_bucket" {
  description = "Bucket containing the Cloud Function source archive."
  type        = string
}

variable "storage_notification_function_source_object" {
  description = "Object containing the storage notification Cloud Function source archive."
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

variable "youtube_data_function_name" {
  description = "YouTube data Cloud Function name."
  type        = string
  default     = "youtube-data-summary"
}

variable "youtube_data_summary_function_source_object" {
  description = "Object containing the YouTube data summary Cloud Function source archive."
  type        = string
}

variable "youtube_output_bucket" {
  description = "Bucket where YouTube search results are stored."
  type        = string
}

variable "youtube_config_object" {
  description = "Object containing the editable YouTube search configuration."
  type        = string
}

variable "youtube_api_key_secret_name" {
  description = "Secret Manager secret containing the YouTube Data API key."
  type        = string
  default     = "youtube_api_key"
}

variable "youtube_search_terms" {
  description = "Comma-separated search terms passed to the YouTube Data API."
  type        = list(string)
  default     = ["GCP Cloud Run"]
}

variable "youtube_result_limit" {
  description = "Maximum search results exported for each term."
  type        = number
  default     = 10

  validation {
    condition     = var.youtube_result_limit >= 1 && var.youtube_result_limit <= 50
    error_message = "youtube_result_limit must be between 1 and 50."
  }
}