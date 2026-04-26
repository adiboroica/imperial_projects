"""SessionRepository unit tests against an in-memory mongomock-motor database."""

from __future__ import annotations

from datetime import datetime, timedelta, timezone

import pytest
from mongomock_motor import AsyncMongoMockClient

from src.models.auth import Session
from src.repositories.session import SessionRepository


@pytest.fixture
async def repo():
    db = AsyncMongoMockClient()["cyoa_test"]
    r = SessionRepository(db)
    await r.ensure_indexes()
    return r


def _session(user="a@b.com", expires_in=timedelta(days=1)) -> Session:
    return Session(
        user_email=user,
        expires_at=datetime.now(timezone.utc) + expires_in,
    )


# --- Core Functionality ---


@pytest.mark.asyncio
async def test_create_and_get_by_id_round_trip(repo):
    s = _session()
    await repo.create(s)
    fetched = await repo.get_by_id(s.id)
    assert fetched is not None
    assert fetched.user_email == "a@b.com"


@pytest.mark.asyncio
async def test_delete_removes_session(repo):
    s = _session()
    await repo.create(s)
    await repo.delete(s.id)
    assert await repo.get_by_id(s.id) is None


@pytest.mark.asyncio
async def test_is_expired_true_when_past(repo):
    expired = Session(
        user_email="a@b.com",
        created_at=datetime.now(timezone.utc) - timedelta(hours=2),
        expires_at=datetime.now(timezone.utc) - timedelta(hours=1),
    )
    assert await repo.is_expired(expired) is True


@pytest.mark.asyncio
async def test_is_expired_false_when_future(repo):
    live = _session(expires_in=timedelta(hours=1))
    assert await repo.is_expired(live) is False


# --- Edge Cases ---


@pytest.mark.asyncio
async def test_get_by_id_unknown_returns_none(repo):
    assert await repo.get_by_id("does-not-exist") is None


@pytest.mark.asyncio
async def test_delete_unknown_is_noop(repo):
    # Idempotent — no exception.
    await repo.delete("does-not-exist")
