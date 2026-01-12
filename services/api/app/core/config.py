# config.py
import os

RAW_BUCKET = os.getenv("RAW_BUCKET", "smmu-dev-raw-media")
JOBS_TABLE = os.getenv("JOBS_TABLE", "smmu-dev-jobs")
QUEUE_URL  = os.getenv("QUEUE_URL")
