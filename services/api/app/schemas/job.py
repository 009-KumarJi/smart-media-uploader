from pydantic import BaseModel

class JobResponse(BaseModel):
    jobId: str
    status: str
    progress: int | None = None
    inputKey: str | None = None
