"""
Home Credit Risk Pipeline DAG

Orchestrates the full data pipeline:
1. kaggle_to_gcs: Runs the ingestion Docker container
2. dbt_run: Placeholder for dbt transformation (Ticket 005)

Schedule: Weekly on Sunday midnight
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.operators.bash import BashOperator
from docker.types import Mount
import os

GCP_PROJECT_ID = os.getenv("GCP_PROJECT_ID")
GCS_BUCKET_NAME = os.getenv("GCS_BUCKET_NAME")
KAGGLE_USERNAME = os.getenv("KAGGLE_USERNAME")
KAGGLE_KEY = os.getenv("KAGGLE_KEY")

default_args = {
    "owner": "peter-okpeh",
    "depends_on_past": False,
    "email": ["peter.a.okpeh@gmail.com"],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="home_credit_pipeline",
    default_args=default_args,
    description="Home Credit Risk — full data pipeline",
    schedule_interval="0 0 * * 0",  # midnight every Sunday
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["home-credit", "ingestion", "production"],
) as dag:

    # Task 1 — Run ingestion container
    kaggle_to_gcs = DockerOperator(
        task_id="kaggle_to_gcs",
        image="home-credit-ingestion:latest",
        container_name="airflow_kaggle_to_gcs",
        api_version="auto",
        auto_remove=True,
        docker_url="unix://var/run/docker.sock",
        network_mode="home-credit-loan_home-credit-network",
        mounts=[
            Mount(
                source="/home/pete/projects/home-credit-loan/data/raw",
                target="/app/data/raw",
                type="bind",
            ),
            Mount(
                source="/home/pete/projects/home-credit-loan/credentials",
                target="/app/credentials",
                type="bind",
            ),
        ],
        environment={
            "GOOGLE_APPLICATION_CREDENTIALS": "/app/credentials/home-credit-app-sa.json",
            "GCP_PROJECT_ID": GCP_PROJECT_ID,
            "GCS_BUCKET_NAME": GCS_BUCKET_NAME,
            "KAGGLE_USERNAME": KAGGLE_USERNAME,
            "KAGGLE_KEY": KAGGLE_KEY,
        },
    )

    # Task 2 — dbt placeholder (will be replaced in Ticket 005)
    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command="echo 'dbt run will be implemented in Ticket 005'",
    )

    # Define task dependencies
    kaggle_to_gcs >> dbt_run

