# uploads.py
import uuid
import time
from fastapi import APIRouter, Depends, Request
import json
from ..core.aws import s3, dynamodb, sqs
from ..core.config import RAW_BUCKET, JOBS_TABLE, QUEUE_URL
from ..schemas.upload import UploadInitRequest, UploadInitResponse
from ..schemas.upload import UploadCompleteRequest
from ..core.auth import verify_token

router = APIRouter()


@router.post("/media/upload/init", response_model=UploadInitResponse, dependencies=[Depends(verify_token)])
def upload_init(data: UploadInitRequest):

    media_id = str(uuid.uuid4())
    key = f"raw/{media_id}-{data.fileName}"

    url = s3.generate_presigned_url(
        "put_object",
        Params={
            "Bucket": RAW_BUCKET,
            "Key": key,
            "ContentType": data.contentType
        },
        ExpiresIn=900
    )

    return {
        "mediaId": media_id,
        "s3Key": key,
        "uploadUrl": url
    }


@router.post("/media/upload/complete", dependencies=[Depends(verify_token)])
def upload_complete(data: UploadCompleteRequest, req: Request):
    
    user = req.state.user 
    user_id = user["sub"]
    
    job_id = str(uuid.uuid4())
    table = dynamodb.Table(JOBS_TABLE)

    item = {
        "jobId": job_id,
        "userId": user_id,
        "mediaId": data.mediaId,
        "status": "QUEUED",
        "inputKey": data.s3Key,
        "createdAt": int(time.time()),
        "progress": 0
    }

    table.put_item(Item=item)

    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps(item)
    )


    return {
        "jobId": job_id,
        "status": "QUEUED"
    }