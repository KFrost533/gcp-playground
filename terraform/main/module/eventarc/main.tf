data "google_project" "this" {
  project_id = var.project_id
}

resource "google_project_service" "eventarc" {
  project = var.project_id
  service = "eventarc.googleapis.com"
}

resource "google_project_service" "pubsub" {
  project = var.project_id
  service = "pubsub.googleapis.com"
}

resource "google_service_account" "eventarc" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Eventarc trigger service account"
}

resource "google_project_iam_member" "eventarc_receiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.eventarc.email}"
}

resource "google_project_iam_member" "function_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.eventarc.email}"
}

resource "google_project_iam_member" "storage_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.this.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_eventarc_trigger" "storage_finalize" {
  project         = var.project_id
  name            = var.trigger_name
  location        = var.location
  service_account = google_service_account.eventarc.email

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }

  matching_criteria {
    attribute = "bucket"
    value     = var.bucket_name
  }

  destination {
    cloud_function = "projects/${var.project_id}/locations/${var.location}/functions/${var.cloud_function_name}"
  }

  depends_on = [
    google_project_service.eventarc,
    google_project_service.pubsub,
    google_project_iam_member.eventarc_receiver,
    google_project_iam_member.function_invoker,
    google_project_iam_member.storage_pubsub_publisher
  ]
}