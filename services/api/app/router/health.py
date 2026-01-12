# health.py
from fastapi import APIRouter, Depends
from ..core.auth import verify_token

router = APIRouter()

@router.get("/health")
def health():
    return {
        "status": "ok",
        "service": "smmu-api"
    }

@router.get("/health-protected", dependencies=[Depends(verify_token)])
def health():
    return {
        "status": "ok",
        "service": "smmu-api"
    }
