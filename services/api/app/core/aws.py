# aws.py
import os

import boto3
from botocore.config import Config

REGION = os.getenv("AWS_REGION", "ap-south-1")
S3_ENDPOINT = f"https://s3.{REGION}.amazonaws.com"

s3 = boto3.client(
    "s3",
    region_name=REGION,
    endpoint_url=S3_ENDPOINT,
    config=Config(signature_version="s3v4", s3={"addressing_style": "virtual"})
)
dynamodb = boto3.resource("dynamodb", region_name=REGION)
sqs = boto3.client("sqs", region_name=REGION)
