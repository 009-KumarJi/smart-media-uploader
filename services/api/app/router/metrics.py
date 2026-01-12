# metrics.py
from fastapi import APIRouter
from ..core.aws import dynamodb
from ..core.config import JOBS_TABLE

router = APIRouter()

@router.get("/metrics")
def metrics():
    table = dynamodb.Table(JOBS_TABLE)

    res = table.scan(
        ProjectionExpression="#s",
        ExpressionAttributeNames={"#s": "status"}
    )

    stats = {
        "QUEUED": 0,
        "RUNNING": 0,
        "COMPLETED": 0,
        "FAILED": 0
    }

    for i in res["Items"]:
        if i["status"] in stats:
            stats[i["status"]] += 1

    return {
        "jobs": stats
    }
