"""FastAPI application entrypoint."""

from __future__ import annotations

import logging
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from src.config import get_app_url
from src.db import close_db, connect_db
from src.dependencies import ensure_indexes, reset_singletons
from src.models.errors import RepositoryError
from src.routers import api_key, auth, stories, ws


_DEV_FALLBACK_ENCRYPTION_KEY = "dev-only-not-secure-change-me-now"


def _configure_logging() -> None:
    level = os.getenv("LOG_LEVEL", "INFO").upper()
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)-8s %(name)s — %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S%z",
    )


def _is_dev_mode() -> bool:
    return os.getenv("DEV", "").lower() in ("true", "1", "yes")


def _validate_required_env() -> None:
    """Fail-fast in production if security-critical env vars are missing or default."""
    if _is_dev_mode():
        return
    encryption_key = os.getenv("ENCRYPTION_KEY", "")
    if not encryption_key or encryption_key == _DEV_FALLBACK_ENCRYPTION_KEY:
        raise RuntimeError(
            "ENCRYPTION_KEY must be set to a non-default value in production. "
            "Set DEV=true to override during local development."
        )
    if not os.getenv("OPENAI_API_KEY", "").strip():
        raise RuntimeError(
            "OPENAI_API_KEY must be set in production. "
            "Set DEV=true to override during local development."
        )


def _cors_origins() -> list[str]:
    """`get_app_url` is already trailing-slash-stripped; CORS expects exactly one entry."""
    return [get_app_url()]


@asynccontextmanager
async def lifespan(app: FastAPI):
    _configure_logging()
    _validate_required_env()
    reset_singletons()
    await connect_db()
    await ensure_indexes()
    logging.getLogger("src").info("Backend ready")
    yield
    await close_db()


app = FastAPI(lifespan=lifespan)

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter


@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request, exc):
    return JSONResponse(status_code=429, content={"detail": "Rate limit exceeded"})


@app.exception_handler(RepositoryError)
async def repository_error_handler(request, exc: RepositoryError):
    """Translate any uncaught Mongo failure into a generic 503 — never leak driver internals."""
    logging.getLogger(__name__).exception("RepositoryError", exc_info=exc)
    return JSONResponse(
        status_code=503, content={"detail": "Service temporarily unavailable"}
    )


app.add_middleware(
    CORSMiddleware,
    allow_origins=_cors_origins(),
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
    max_age=1000,
)


@app.get("/health", tags=["health"])
async def health() -> dict[str, str]:
    """Liveness + readiness probe used by docker-compose healthcheck."""
    return {"status": "ok"}


app.include_router(auth.router)
app.include_router(stories.router)
app.include_router(api_key.router)
app.include_router(ws.router)


if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", 8000))
    uvicorn.run("src.main:app", host="0.0.0.0", port=port)
