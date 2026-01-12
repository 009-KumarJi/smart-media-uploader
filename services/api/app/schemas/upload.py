from pydantic import BaseModel

class UploadInitRequest(BaseModel):
    fileName: str
    contentType: str


class UploadInitResponse(BaseModel):
    mediaId: str
    s3Key: str
    uploadUrl: str


class UploadCompleteRequest(BaseModel):
    mediaId: str
    s3Key: str
