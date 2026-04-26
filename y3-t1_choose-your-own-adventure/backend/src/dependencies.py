"""FastAPI dependency providers — wires repositories, services, and the current-user check.

Repositories are process-wide singletons (memoised via `functools.lru_cache`) so each one
holds a single `AsyncIOMotorDatabase` reference. Services are constructed per request from
those singletons; construction is cheap (just stores a ref). Tests override these providers
through `app.dependency_overrides`.
"""

from __future__ import annotations

from functools import lru_cache

from fastapi import Depends, HTTPException, Request

from src.db import get_db
from src.models.auth import User
from src.models.errors import (
    SessionExpired,
    SessionNotFound,
    Unauthenticated,
    UserNotFound,
)
from src.repositories import (
    SessionRepository,
    StoryRepository,
    UserRepository,
)
from src.services import (
    ApiKeyService,
    AuthService,
    ExportService,
    GenerationService,
    StoryService,
)


# ---------- Repositories (singletons) ----------


@lru_cache(maxsize=1)
def _user_repository_instance() -> UserRepository:
    return UserRepository(get_db())


@lru_cache(maxsize=1)
def _session_repository_instance() -> SessionRepository:
    return SessionRepository(get_db())


@lru_cache(maxsize=1)
def _story_repository_instance() -> StoryRepository:
    return StoryRepository(get_db())


def get_user_repository() -> UserRepository:
    return _user_repository_instance()


def get_session_repository() -> SessionRepository:
    return _session_repository_instance()


def get_story_repository() -> StoryRepository:
    return _story_repository_instance()


# ---------- Services (per-request) ----------


def get_auth_service(
    user_repo: UserRepository = Depends(get_user_repository),
    session_repo: SessionRepository = Depends(get_session_repository),
) -> AuthService:
    return AuthService(user_repo, session_repo)


def get_story_service(
    story_repo: StoryRepository = Depends(get_story_repository),
) -> StoryService:
    return StoryService(story_repo)


def get_api_key_service(
    user_repo: UserRepository = Depends(get_user_repository),
) -> ApiKeyService:
    return ApiKeyService(user_repo)


def get_generation_service() -> GenerationService:
    return GenerationService()


def get_export_service(
    story_repo: StoryRepository = Depends(get_story_repository),
) -> ExportService:
    return ExportService(story_repo)


# ---------- Auth ----------


COOKIE_NAME = "cyoa_session"


async def get_current_user(
    request: Request,
    auth: AuthService = Depends(get_auth_service),
) -> User:
    session_id = request.cookies.get(COOKIE_NAME)
    try:
        return await auth.validate_session(session_id)
    except (Unauthenticated, SessionNotFound, SessionExpired, UserNotFound) as exc:
        raise HTTPException(status_code=401) from exc


# ---------- Lifespan helpers ----------


async def ensure_indexes() -> None:
    """Called from `main.py`'s lifespan on startup. Idempotent."""
    await _user_repository_instance().ensure_indexes()
    await _session_repository_instance().ensure_indexes()
    await _story_repository_instance().ensure_indexes()


def reset_singletons() -> None:
    """Test helper — clear the cached repository singletons."""
    _user_repository_instance.cache_clear()
    _session_repository_instance.cache_clear()
    _story_repository_instance.cache_clear()
