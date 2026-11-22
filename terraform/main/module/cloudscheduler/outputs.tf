output "job_name" {
  description = "Name of the YouTube export scheduler job."
  value       = google_cloud_scheduler_job.youtube_data_summary.name
}
