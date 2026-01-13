# identity.py
from fastapi import APIRouter, Depends, Request
from ..core.auth import verify_token

router = APIRouter()

@router.get("/me", dependencies=[Depends(verify_token)])
def me(req: Request):
    user = req.state.user
    return {
        "userId": user["sub"]
    }
