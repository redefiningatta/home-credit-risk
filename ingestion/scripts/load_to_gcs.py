
"""
Ingestion Script: Local CSV files -> Google Cloud Storage

This script:
1. Reads raw CSV files from data/raw/
2. Validates each file exists and is readable
3. Uploads to GCS bucket in parallel (max 3 concurrent uploads)
4. Logs progress and any errors
 
from pathlib import Path
from dotenv import load_dotenv
from google.cloud import storage
from concurrent.futures import ThreadPoolExecutor, as_completed

# -- Configuration -----------------------------------------------------
load_dotenv()

GCP_PROJECT_ID = os.getenv("GCP_PROJECT_ID")
GCS_BUCKET_NAME = os.getenv("GCS_BUCKET_NAME")
RAW_DATA_PATH = Path("data/raw")
GCS_DESTINATION_PREFIX = "home-credit/raw"
MAX_WORKERS = 3  # safe limit for GCS API rate limits

# -- Logging -----------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# -- Files to upload ---------------------------------------------------
TARGET_FILES = [
    "application_train.csv",
    "application_test.csv",
    "bureau.csv",
    "bureau_balance.csv",
    "previous_application.csv",
    "POS_CASH_balance.csv",
    "credit_card_balance.csv",
    "installments_payments.csv",
    "HomeCredit_columns_description.csv",
]


def validate_environment() -> None:
    """Validate all required environment variables are set."""
    required = ["GCP_PROJECT_ID", "GCS_BUCKET_NAME", "GOOGLE_APPLICATION_CREDENTIALS"]
    missing = [var for var in required if not os.getenv(var)]
    if missing:
        raise EnvironmentError(f"Missing required environment variables: {missing}")
    logger.info("Environment validation passed")


def get_gcs_client() -> storage.Client:
    """Initialise and return a GCS client."""
    client = storage.Client(project=GCP_PROJECT_ID)
    logger.info(f"GCS client initialised for project: {GCP_PROJECT_ID}")
    return client


def upload_file_to_gcs(
    client: storage.Client,
    local_path: Path,
    bucket_name: str,
    destination_prefix: str,
) -> tuple[str, bool, str]:
    """
    Upload a single file to GCS with resumable upload for large files.

    Args:
        client: Authenticated GCS client
        local_path: Path to the local file
        bucket_name: Target GCS bucket name
        destination_prefix: Folder prefix in GCS

    Returns:
        Tuple of (filename, success, error_message)
    """
    try:
        bucket = client.bucket(bucket_name)
        destination_blob = f"{destination_prefix}/{local_path.name}"
        blob = bucket.blob(destination_blob)

        file_size_mb = local_path.stat().st_size / (1024 * 1024)
        logger.info(f"Uploading {local_path.name} ({file_size_mb:.1f} MB) -> gs://{bucket_name}/{destination_blob}")

        # Use resumable upload for files over 100MB for reliability
        if file_size_mb > 100:
            with open(local_path, "rb") as f:
                blob.upload_from_file(
                    f,
                    timeout=600,      # 10 minute timeout for large files
                    checksum="md5",   # verify integrity after upload
                )
        else:
            blob.upload_from_filename(
                str(local_path),
                timeout=300,
            )

        logger.info(f"Uploaded {local_path.name} ({file_size_mb:.1f} MB)")
        return (local_path.name, True, "")

    except Exception as e:
        logger.error(f"Failed to upload {local_path.name}: {e}")
        return (local_path.name, False, str(e))


def main() -> None:
    """Main ingestion pipeline with parallel uploads."""
    logger.info("Starting ingestion pipeline: Local CSV -> GCS")
    logger.info(f"Source: {RAW_DATA_PATH}")
    logger.info(f"Destination: gs://{GCS_BUCKET_NAME}/{GCS_DESTINATION_PREFIX}")
    logger.info(f"Parallel workers: {MAX_WORKERS}")

    validate_environment()
    client = get_gcs_client()

    results = {"success": [], "failed": [], "missing": []}

    # Separate existing files from missing ones
    files_to_upload = []
    for filename in TARGET_FILES:
        local_path = RAW_DATA_PATH / filename
        if not local_path.exists():
            logger.warning(f"File not found, skipping: {filename}")
            results["missing"].append(filename)
        else:
            files_to_upload.append(local_path)

    # Upload in parallel with bounded thread pool
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = {
            executor.submit(
                upload_file_to_gcs,
                client,
                local_path,
                GCS_BUCKET_NAME,
                GCS_DESTINATION_PREFIX,
            ): local_path.name
            for local_path in files_to_upload
        }

        for future in as_completed(futures):
            filename, success, error = future.result()
            if success:
                results["success"].append(filename)
            else:
                results["failed"].append((filename, error))

    # Summary
    logger.info("=" * 50)
    logger.info("INGESTION SUMMARY")
    logger.info(f"Successful: {len(results['success'])} files")
    logger.info(f"Failed:     {len(results['failed'])} files")
    logger.info(f"Missing:    {len(results['missing'])} files")

    if results["failed"]:
        for filename, error in results["failed"]:
            logger.error(f"  {filename}: {error}")
        raise RuntimeError("Some files failed to upload")

    logger.info("Ingestion pipeline complete")


if __name__ == "__main__":
    main()
