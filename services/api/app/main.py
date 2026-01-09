from fastapi import FastAPI
from .routes import router

app = FastAPI(title="Media Vault")

app.include_router(router)
