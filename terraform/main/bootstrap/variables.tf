variable "project_id" {
  description = "The GCP project ID."
  type        = string
  default     = "event-driven-notification"
}

variable "youtube_search_terms" {
  description = "Search terms used by the scheduled YouTube export."
  type        = list(string)
  default     = ["GCP Cloud Run"]
}

variable "youtube_result_limit" {
  description = "Maximum results exported for each YouTube search term."
  type        = number
  default     = 10
}

variable "youtube_schedule" {
  description = "Cloud Scheduler cron expression for YouTube searches."
  type        = string
  default     = "0 9 * * *"
}

variable "youtube_schedule_timezone" {
  description = "IANA time zone used by the Cloud Scheduler job."
  type        = string
  default     = "Asia/Tokyo"
}