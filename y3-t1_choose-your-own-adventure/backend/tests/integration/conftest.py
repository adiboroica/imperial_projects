"""Integration test fixtures.

Each test gets a fresh FastAPI app whose repositories point at an
in-memory mongomock-motor database, plus a fresh `httpx.AsyncClient`
session that maintains the auth cookie across requests.
"""

from __future__ import annotations

from typing import AsyncIterator
from unittest.mock import AsyncMock

import pytest
from httpx import ASGITransport, AsyncClient
from mongomock_motor import AsyncMongoMockClient

from src.dependencies import (
    get_generation_service,
    get_session_repository,
    get_story_repository,
    get_user_repository,
)
from src.main import app
from src.repositories import (
    SessionRepository,
    StoryRepository,
    UserRepository,
)
from src.routers import auth as auth_router


@pytest.fixture
async def mock_db():
    client = AsyncMongoMockClient()
    return client["cyoa_test"]


@pytest.fixture
async def overridden_app(mock_db):
    """Configures the live FastAPI app with mock repositories and a stub LLM."""
    user_repo = UserRepository(mock_db)
    session_repo = SessionRepository(mock_db)
    story_repo = StoryRepository(mock_db)
    await user_repo.ensure_indexes()
    await session_repo.ensure_indexes()
    await story_repo.ensure_indexes()

    # Stub generation so WS tests don't need real OpenAI.
    fake_generation = AsyncMock()

    # Reset slowapi's per-IP counters between tests — without this, the in-
    # memory `MemoryStorage` accumulates across the whole pytest session and
    # every test after ~5 signups gets a 429. Two separate `Limiter`
    # instances exist (`app.state.limiter` for the rate-limit handler and
    # `routers.auth.limiter` for the @limit decorators); reset both.
    for lim in (getattr(app.state, "limiter", None), auth_router.limiter):
        storage = getattr(lim, "_storage", None)
        if storage is not None and hasattr(storage, "reset"):
            storage.reset()

    app.dependency_overrides[get_user_repository] = lambda: user_repo
    app.dependency_overrides[get_session_repository] = lambda: session_repo
    app.dependency_overrides[get_story_repository] = lambda: story_repo
    app.dependency_overrides[get_generation_service] = lambda: fake_generation

    app.state.test_user_repo = user_repo
    app.state.test_story_repo = story_repo
    app.state.test_generation = fake_generation
    yield app
    app.dependency_overrides.clear()


@pytest.fixture
async def client(overridden_app) -> AsyncIterator[AsyncClient]:
    transport = ASGITransport(app=overridden_app)
    async with AsyncClient(
        transport=transport, base_url="http://testserver"
    ) as c:
        yield c


@pytest.fixture
async def signed_up_client(client: AsyncClient) -> AsyncClient:
    """Client with an active session via signup."""
    response = await client.post(
        "/auth/signup",
        json={"email": "tester@example.com", "password": "password123"},
    )
    assert response.status_code == 201, response.text
    return client
