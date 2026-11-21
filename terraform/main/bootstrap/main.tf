terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

variable "gcp_secret_project_id" {
  description = "Existing GCP project ID containing the Secret Manager values."
  type        = string
  default     = "parameter-store-505395"
}

variable "gcp_region" {
  description = "The GCP region."
  default     = "australia-southeast1" # Sydney region
  type        = string
}

provider "google" {
  project = var.gcp_secret_project_id
  region  = var.gcp_region
}

# Secret Manager data sources
data "google_secret_manager_secret_version" "gcp_account_id" {
  project = var.gcp_secret_project_id
  secret  = "gcp_account_id"
}

data "google_secret_manager_secret_version" "gcp_account_name" {
  project = var.gcp_secret_project_id
  secret  = "gcp_account_name"
}

data "google_secret_manager_secret_version" "gcp_billing_account" {
  project = var.gcp_secret_project_id
  secret  = "gcp_billing_account"
}

resource "google_project" "this" {
  project_id      = data.google_secret_manager_secret_version.gcp_account_id.secret_data
  name            = data.google_secret_manager_secret_version.gcp_account_name.secret_data
  billing_account = data.google_secret_manager_secret_version.gcp_billing_account.secret_data

  labels = {
    for_learning    = "true"
    project         = "event-driven-notification"
    managed_by      = "terraform"
  }

  lifecycle {
  }
}

module "cloudstorage" {
  source       = "../module/cloudstorage"
  project_id   = google_project.this.project_id
  project_name = google_project.this.name
}