from fastapi import APIRouter
from ..core.aws import dynamodb
from ..core.config import JOBS_TABLE

router = APIRouter()

@router.get("/metrics")
def metrics():
    table = dynamodb.Table(JOBS_TABLE)
    res = table.scan()

    jobs = res.get("Items", [])

    return {
        "totalJobs": len(jobs),
        "running": len([j for j in jobs if j["status"] == "RUNNING"]),
        "queued": len([j for j in jobs if j["status"] == "QUEUED"]),
        "completed": len([j for j in jobs if j["status"] in ["TRANSCODED", "DONE"]])
    }
