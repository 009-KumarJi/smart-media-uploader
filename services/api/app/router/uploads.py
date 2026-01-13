# uploads.py
import uuid
import time
import mimetypes
from fastapi import APIRouter, Depends, Request, HTTPException
import json
from ..core.aws import s3, dynamodb, sqs
from ..core.config import RAW_BUCKET, JOBS_TABLE, QUEUE_URL
from ..schemas.upload import UploadInitRequest, UploadInitResponse
from ..schemas.upload import UploadCompleteRequest
from ..core.auth import verify_token

router = APIRouter()


@router.post("/media/upload/init", response_model=UploadInitResponse, dependencies=[Depends(verify_token)])
def upload_init(data: UploadInitRequest, req: Request):

    user_id = req.state.user["sub"]

    upload_id = str(uuid.uuid4())
    media_id = str(uuid.uuid4())
    s3_key = f"raw/{user_id}/{media_id}-{data.fileName}"

    url = s3.generate_presigned_url(
        "put_object",
        Params={
            "Bucket": RAW_BUCKET,
            "Key": s3_key,
            "ContentType": data.contentType
        },
        ExpiresIn=900
    )

    uploads = dynamodb.Table("smmu-dev-upload-sessions")

    uploads.put_item(Item={
        "uploadId": upload_id,
        "userId": user_id,
        "s3Key": s3_key,
        "contentType": data.contentType,
        "maxSize": 500 * 1024 * 1024,   # 500 MB
        "status": "INIT",
        "expiresAt": int(time.time()) + 900
    })

    return {
        "uploadId": upload_id,
        "s3Key": s3_key,
        "uploadUrl": url
    }


@router.post("/media/upload/complete", dependencies=[Depends(verify_token)])
def upload_complete(data: UploadCompleteRequest, req: Request):

    user_id = req.state.user["sub"]
    upload_id = data.uploadId

    uploads = dynamodb.Table("smmu-dev-upload-sessions")
    jobs = dynamodb.Table(JOBS_TABLE)

    session = uploads.get_item(Key={"uploadId": upload_id}).get("Item")


    if not session or session["userId"] != user_id:
        raise HTTPException(status_code=403, detail="Invalid upload session")

    if session["status"] != "INIT":
        raise HTTPException(status_code=400, detail="Upload already used")

    if session["expiresAt"] < int(time.time()):
        raise HTTPException(410, "Upload session expired")
    
    head = s3.head_object(Bucket=RAW_BUCKET, Key=session["s3Key"])
    size = head["ContentLength"]
    max_size = session["maxSize"]

    if size > max_size:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Max allowed {max_size/1024/1024:.0f} MB"
        )


    actual_type = head["ContentType"]
    expected = session["contentType"]

    if actual_type != expected:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid content type. Expected {expected}, got {actual_type}"
        )
    
    ext = session["s3Key"].split(".")[-1]
    mime_from_ext, _ = mimetypes.guess_type("x." + ext)

    if mime_from_ext != actual_type:
        raise HTTPException(
            status_code=400,
            detail="File extension does not match content type"
        )
    
    job_id = str(uuid.uuid4())
    jobs.put_item(Item={
        "jobId": job_id,
        "userId": user_id,
        "inputKey": session["s3Key"],
        "status": "QUEUED",
        "createdAt": int(time.time()),
        "progress": 0,
        "inputBytes": size,
        "mime": actual_type
    })


    uploads.update_item(
        Key={"uploadId": upload_id},
        UpdateExpression="SET #s = :s",
        ExpressionAttributeNames={"#s": "status"},
        ExpressionAttributeValues={":s": "USED"}
    )

    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps({
            "jobId": job_id,
            "userId": user_id,
            "inputKey": session["s3Key"]
        })
    )

    return { "jobId": job_id }
