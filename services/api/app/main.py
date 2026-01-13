# main.py
from fastapi import FastAPI
from .router.uploads import router as uploads_router
from .router.jobs import router as jobs_router
from .router.health import router as health_router
from .router.metrics import router as metrics_router
from .router.ws import router as ws_router
from .router.identity import router as identity_router
from .router.usage import router as usage_router

app = FastAPI(title="Smart Media Uploader")

app.include_router(identity_router)
app.include_router(uploads_router)
app.include_router(jobs_router)
app.include_router(health_router)
app.include_router(metrics_router)
app.include_router(ws_router)
app.include_router(usage_router)