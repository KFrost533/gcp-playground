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