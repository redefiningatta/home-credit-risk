output "gcs_bucket_name" {
  description = "Name of the GCS bucket for raw data"
  value       = google_storage_bucket.raw_data.name
}

output "gcs_bucket_url" {
  description = "URL of the GCS bucket"
  value       = google_storage_bucket.raw_data.url
}

output "bq_raw_dataset" {
  description = "BigQuery raw dataset ID"
  value       = google_bigquery_dataset.raw.dataset_id
}

output "bq_staging_dataset" {
  description = "BigQuery staging dataset ID"
  value       = google_bigquery_dataset.staging.dataset_id
}

output "bq_intermediate_dataset" {
  description = "BigQuery intermediate dataset ID"
  value       = google_bigquery_dataset.intermediate.dataset_id
}

output "bq_marts_dataset" {
  description = "BigQuery marts dataset ID"
  value       = google_bigquery_dataset.marts.dataset_id
}

output "service_account_email" {
  description = "Email of the pipeline service account"
  value       = google_service_account.pipeline_sa.email
}
