# main.py
from fastapi import FastAPI
from .router.uploads import router as uploads_router
from .router.jobs import router as jobs_router
from .router.health import router as health_router
from .router.metrics import router as metrics_router
from .router.ws import router as ws_router

app = FastAPI(title="Smart Media Uploader")

app.include_router(uploads_router)
app.include_router(jobs_router)
app.include_router(health_router)
app.include_router(metrics_router)
app.include_router(ws_router)
