resource "google_storage_bucket" "this" {
  project                     = var.project_id
  name                        = "${var.project_id}-event-notification"
  location                    = var.location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }

    action {
      type = "Delete"
    }
  }

  labels = {
    for_learning = "true"
    project      = lower(replace(var.project_name, " ", "-"))
    managed_by   = "terraform"
  }
}

// Storage notification function source bucket and object
resource "google_storage_bucket" "source" {
  project                     = var.project_id
  name                        = "${var.project_id}-functions-source"
  location                    = var.location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
  labels = {
    project    = lower(replace(var.project_name, " ", "-"))
    managed_by = "terraform"
  }
}

data "archive_file" "storage_notification_source" {
  type        = "zip"
  source_dir  = var.storage_notification_function_source_dir
  output_path = "${path.module}/function-source.zip"
}

resource "google_storage_bucket_object" "source" {
  name   = "storage-notification-${data.archive_file.storage_notification_source.output_md5}.zip"
  bucket = google_storage_bucket.source.name
  source = data.archive_file.storage_notification_source.output_path
}

// YouTube data summary function source bucket and object
resource "google_storage_bucket" "yt_data_summary_source" {
  project                     = var.project_id
  name                        = "${var.project_id}-yt-data-summary-source"
  location                    = var.location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
  labels = {
    project    = lower(replace(var.project_name, " ", "-"))
    managed_by = "terraform"
  }
}

data "archive_file" "youtube_data" {
  type        = "zip"
  source_dir  = var.youtube_data_function_source_dir
  output_path = "${path.module}/yt-data-summary-function-source.zip"
}

resource "google_storage_bucket_object" "youtube_data" {
  name   = "yt-data-summary-${data.archive_file.youtube_data.output_md5}.zip"
  bucket = google_storage_bucket.yt_data_summary_source.name
  source = data.archive_file.youtube_data.output_path
}

resource "google_storage_bucket" "youtube_summary_storage" {
  project                     = var.project_id
  name                        = "${var.project_id}-youtube-summary-storage"
  location                    = var.location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }

    action {
      type = "Delete"
    }
  }

  labels = {
    for_learning = "true"
    project      = lower(replace(var.project_name, " ", "-"))
    managed_by   = "terraform"
  }
}