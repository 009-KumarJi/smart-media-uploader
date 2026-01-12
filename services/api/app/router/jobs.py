# jobs.py
from fastapi import APIRouter, Depends, HTTPException, Request
from ..core.aws import dynamodb
from ..core.config import JOBS_TABLE
from ..schemas.job import JobResponse
from ..core.auth import verify_token

router = APIRouter()

@router.get("/jobs/{job_id}", dependencies=[Depends(verify_token)])
def get_job_status(job_id: str, request: Request):
    
    user_id = request.state.user["sub"]
    table = dynamodb.Table(JOBS_TABLE)

    # 1. Fetch Job
    response = table.get_item(Key={"jobId": job_id, "userId": user_id})
    item = response.get("Item")

    # 2. Check if job exists
    if not item:
        raise HTTPException(status_code=404, detail="Job not found")

    # 3. 🔥 SECURITY CHECK: Does this job belong to the caller?
    if item.get("userId") != user_id:
        # Lie to them. Don't say "It's not yours", say "Not found" for extra security.
        raise HTTPException(status_code=404, detail="Job not found") 

    return item