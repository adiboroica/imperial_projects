"""UserRepository unit tests against an in-memory mongomock-motor database."""

from __future__ import annotations

import pytest
from mongomock_motor import AsyncMongoMockClient

from src.models.auth import User
from src.models.errors import EmailAlreadyExists, UserNotFound
from src.repositories.user import UserRepository


@pytest.fixture
async def repo():
    db = AsyncMongoMockClient()["cyoa_test"]
    r = UserRepository(db)
    await r.ensure_indexes()
    return r


# --- Core Functionality ---


@pytest.mark.asyncio
async def test_create_and_get_by_email_round_trip(repo):
    user = User(email="a@b.com", password_hash="$2b$12$abc")
    await repo.create(user)
    fetched = await repo.get_by_email("a@b.com")
    assert fetched is not None
    assert fetched.email == "a@b.com"


@pytest.mark.asyncio
async def test_get_by_email_unknown_returns_none(repo):
    assert await repo.get_by_email("missing@b.com") is None


@pytest.mark.asyncio
async def test_set_api_key_writes_field(repo):
    await repo.create(User(email="a@b.com", password_hash="$"))
    await repo.set_api_key("a@b.com", "encrypted-cipher")
    fetched = await repo.get_by_email("a@b.com")
    assert fetched is not None
    assert fetched.api_key == "encrypted-cipher"


# --- Edge Cases ---


@pytest.mark.asyncio
async def test_create_with_duplicate_email_raises_email_already_exists(repo):
    await repo.create(User(email="a@b.com", password_hash="$"))
    with pytest.raises(EmailAlreadyExists):
        await repo.create(User(email="a@b.com", password_hash="$"))


@pytest.mark.asyncio
async def test_set_api_key_for_unknown_email_raises_user_not_found(repo):
    with pytest.raises(UserNotFound):
        await repo.set_api_key("missing@b.com", "anything")
