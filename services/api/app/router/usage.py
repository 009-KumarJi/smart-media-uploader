from fastapi import APIRouter, Depends, Request
from ..core.aws import dynamodb
from ..core.config import JOBS_TABLE
from ..core.auth import verify_token

router = APIRouter()

@router.get("/usage", dependencies=[Depends(verify_token)])
def usage(req: Request):
    user_id = req.state.user["sub"]
    table = dynamodb.Table(JOBS_TABLE)

    res = table.scan(
        FilterExpression="userId = :u",
        ExpressionAttributeValues={":u": user_id}
    )

    jobs = res.get("Items", [])

    total_jobs = len(jobs)
    completed = len([j for j in jobs if j["status"] in ["TRANSCODED", "DONE"]])

    return {
        "totalJobs": total_jobs,
        "completedJobs": completed
    }
