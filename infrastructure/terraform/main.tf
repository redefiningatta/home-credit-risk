terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ── GCS Bucket ────────────────────────────────────────────────
resource "google_storage_bucket" "raw_data" {
  name          = var.gcs_bucket_name
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
}

# ── BigQuery Datasets ─────────────────────────────────────────
resource "google_bigquery_dataset" "raw" {
  dataset_id  = var.bq_dataset_raw
  location    = var.region
  description = "Raw Kaggle data — never modified"
}

resource "google_bigquery_dataset" "staging" {
  dataset_id  = var.bq_dataset_staging
  location    = var.region
  description = "dbt staging models"
}

resource "google_bigquery_dataset" "intermediate" {
  dataset_id  = var.bq_dataset_intermediate
  location    = var.region
  description = "dbt intermediate models"
}

resource "google_bigquery_dataset" "marts" {
  dataset_id  = var.bq_dataset_marts
  location    = var.region
  description = "dbt mart models — analytics ready"
}

# ── Service Account ───────────────────────────────────────────
resource "google_service_account" "pipeline_sa" {
  account_id   = var.service_account_name
  display_name = "Home Credit Pipeline Service Account"
  description  = "Used by dbt, Airflow and ingestion scripts"
}

# ── IAM Roles for Service Account ────────────────────────────
resource "google_project_iam_member" "bq_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}
