variable "project_id"{
  description = "The GCP project ID"
  type = string
}

variable "region" {
  description = "The GCP region for all resources"
  type = string 
  default = "europe-west2"

}

variable "gcs_bucket_name" {

  description = "Name of the GCS bucket for raw Kaggle data"
  type = string

}

variable "bq_dataset_raw" {
  description = "BigQuery dataset for raw data"
  type        = string
  default     = "raw"
}

variable "bq_dataset_staging" {
  description = "BigQuery dataset for dbt staging models"
  type        = string
  default     = "staging"
}

variable "bq_dataset_intermediate" {
  description = "BigQuery dataset for dbt intermediate models"
  type        = string
  default     = "intermediate"
}

variable "bq_dataset_marts" {
  description = "BigQuery dataset for dbt mart models"
  type        = string
  default     = "marts"
}

variable "service_account_name" {
  description = "Name of the GCP service account"
  type        = string
  default     = "home-credit-pipeline"
}
