terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
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

data "google_secret_manager_secret_version" "mail_address" {
  project = var.gcp_secret_project_id
  secret  = "mail_address"
}

locals {
  gcp_account_name    = data.google_secret_manager_secret_version.gcp_account_name.secret_data
  gcp_account_id      = data.google_secret_manager_secret_version.gcp_account_id.secret_data
  gcp_billing_account = data.google_secret_manager_secret_version.gcp_billing_account.secret_data
}

module "cloudstorage" {
  source                                   = "../module/cloudstorage"
  project_id                               = nonsensitive(local.gcp_account_id)
  project_name                             = nonsensitive(local.gcp_account_name)
  location                                 = var.gcp_region
  storage_notification_function_source_dir = "${path.module}/../module/cloudfunction/src/storage_notification"
  youtube_data_function_source_dir         = "${path.module}/../module/cloudfunction/src/ytdata_summary"
}

module "pubsub" {
  source = "../module/pubsub"

  project_id = nonsensitive(local.gcp_account_id)
}

module "iam" {
  source = "../module/iam"

  project_id = nonsensitive(local.gcp_account_id)
}

module "cloudfunction" {
  source = "../module/cloudfunction"

  project_id                     = nonsensitive(local.gcp_account_id)
  secret_project_id              = var.gcp_secret_project_id
  location                       = var.gcp_region
  notification_email             = nonsensitive(data.google_secret_manager_secret_version.mail_address.secret_data)
  bucket_name                    = module.cloudstorage.bucket_name
  function_source_bucket         = module.cloudstorage.function_source_bucket
  function_source_object         = module.cloudstorage.function_source_object
  youtube_function_source_bucket = module.cloudstorage.youtube_function_source_bucket
  youtube_function_source_object = module.cloudstorage.youtube_function_source_object
  youtube_output_bucket          = module.cloudstorage.youtube_output_bucket
  youtube_search_terms           = var.youtube_search_terms
  youtube_result_limit           = var.youtube_result_limit
  eventarc_service_account_email = module.iam.service_account_email

  depends_on = [module.pubsub, module.iam, module.eventarc]
}

module "cloudscheduler" {
  source = "../module/cloudscheduler"

  project_id            = nonsensitive(local.gcp_account_id)
  location              = var.gcp_region
  job_name              = "youtube-data-summary-daily"
  function_uri          = module.cloudfunction.youtube_function_uri
  service_account_email = module.cloudfunction.youtube_service_account_email
  schedule              = var.youtube_schedule
  timezone              = var.youtube_schedule_timezone
}

module "eventarc" {
  source = "../module/eventarc"

  project_id = nonsensitive(local.gcp_account_id)
}