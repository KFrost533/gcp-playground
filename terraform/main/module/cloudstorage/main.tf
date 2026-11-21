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
