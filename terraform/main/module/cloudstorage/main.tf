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

data "archive_file" "source" {
  type        = "zip"
  source_dir  = var.function_source_dir
  output_path = "${path.module}/function-source.zip"
}

resource "google_storage_bucket_object" "source" {
  name   = "storage-notification-${data.archive_file.source.output_md5}.zip"
  bucket = google_storage_bucket.source.name
  source = data.archive_file.source.output_path
}