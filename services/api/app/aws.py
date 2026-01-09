import boto3
import os

REGION = os.getenv("AWS_REGION", "ap-south-1")

s3 = boto3.client("s3", region_name=REGION)
dynamodb = boto3.resource("dynamodb", region_name=REGION)
sqs = boto3.client("sqs", region_name=REGION)
