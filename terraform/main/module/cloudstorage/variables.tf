variable "project_id" {
  description = "GCP project ID where the buckets are created."
  type        = string
}

variable "project_name" {
  description = "Display name of the GCP project."
  type        = string
}

variable "location" {
  description = "Cloud Storage bucket location."
  type        = string
  default     = "AUSTRALIA-SOUTHEAST1"
}

variable "function_source_dir" {
  description = "Directory containing the Cloud Function source code."
  type        = string
}
