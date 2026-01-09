import uuid
import time
from fastapi import APIRouter
from .aws import s3, dynamodb, sqs
from .config import RAW_BUCKET, JOBS_TABLE, QUEUE_URL

router = APIRouter()

@router.post("/media/upload/init")
def upload_init(data: dict):
    media_id = str(uuid.uuid4())
    key = f"raw/{media_id}-{data['fileName']}"

    url = s3.generate_presigned_url(
        "put_object",
        Params={
            "Bucket": RAW_BUCKET,
            "Key": key,
            "ContentType": data["contentType"]
        },
        ExpiresIn=900
    )

    return {
        "mediaId": media_id,
        "s3Key": key,
        "uploadUrl": url
    }


@router.post("/media/upload/complete")
def upload_complete(data: dict):
    job_id = str(uuid.uuid4())
    table = dynamodb.Table(JOBS_TABLE)

    item = {
        "jobId": job_id,
        "mediaId": data["mediaId"],
        "status": "QUEUED",
        "inputKey": data["s3Key"],
        "createdAt": int(time.time()),
        "progress": 0
    }

    table.put_item(Item=item)

    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=str(item)
    )

    return {
        "jobId": job_id,
        "status": "QUEUED"
    }


@router.get("/jobs/{job_id}")
def get_job(job_id: str):
    table = dynamodb.Table(JOBS_TABLE)
    res = table.get_item(Key={"jobId": job_id})
    return res.get("Item", {})
