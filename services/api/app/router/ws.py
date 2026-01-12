# ws.py
from fastapi import WebSocket, APIRouter, Depends, Request
import asyncio
from ..core.auth import verify_token
from ..core.aws import dynamodb
from ..core.config import JOBS_TABLE

router = APIRouter()

@router.websocket("/ws/jobs/{job_id}", dependencies=[Depends(verify_token)])
async def job_ws(ws: WebSocket, job_id: str, req: Request):
    await ws.accept()
    table = dynamodb.Table(JOBS_TABLE)

    user = req.state.user 
    user_id = user["sub"]

    last_status = None

    while True:
        res = table.get_item(Key={"jobId": job_id, "userId": user_id})
        job = res.get("Item")

        if job:
            if job["status"] != last_status:
                await ws.send_json(job)
                last_status = job["status"]

            if job["status"] in ["COMPLETED", "FAILED"]:
                break

        await asyncio.sleep(2)

    await ws.close()
