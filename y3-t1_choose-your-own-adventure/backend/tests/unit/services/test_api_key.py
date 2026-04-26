"""ApiKeyService unit tests."""

from __future__ import annotations

import pytest

from src.models.auth import User
from src.models.errors import ApiKeyCorrupted, UserNotFound
from src.services.api_key import ApiKeyService


@pytest.fixture
def api_key_service(mocked_user_repository, env_vars):
    env_vars("ENCRYPTION_KEY", "test-encryption-key-fixed")
    return ApiKeyService(mocked_user_repository)


# --- Core Functionality ---


@pytest.mark.asyncio
async def test_get_for_user_returns_decrypted_key(
    api_key_service, mocked_user_repository
):
    encrypted = api_key_service._encrypt("sk-test-12345")
    mocked_user_repository.get_by_email.return_value = User(
        email="a@b.com", password_hash="$", api_key=encrypted
    )
    result = await api_key_service.get_for_user("a@b.com")
    assert result == "sk-test-12345"


@pytest.mark.asyncio
async def test_get_for_user_with_no_key_returns_none(
    api_key_service, mocked_user_repository
):
    mocked_user_repository.get_by_email.return_value = User(
        email="a@b.com", password_hash="$", api_key=None
    )
    result = await api_key_service.get_for_user("a@b.com")
    assert result is None


@pytest.mark.asyncio
async def test_update_for_user_encrypts_and_stores(
    api_key_service, mocked_user_repository
):
    await api_key_service.update_for_user("a@b.com", "sk-new-key")
    mocked_user_repository.set_api_key.assert_awaited_once()
    args = mocked_user_repository.set_api_key.await_args
    email, encrypted = args.args
    assert email == "a@b.com"
    assert encrypted != "sk-new-key"  # actually encrypted


# --- Edge Cases ---


@pytest.mark.asyncio
async def test_get_for_unknown_user_raises_user_not_found(
    api_key_service, mocked_user_repository
):
    mocked_user_repository.get_by_email.return_value = None
    with pytest.raises(UserNotFound):
        await api_key_service.get_for_user("missing@b.com")


@pytest.mark.asyncio
async def test_update_with_empty_key_raises_value_error(api_key_service):
    with pytest.raises(ValueError):
        await api_key_service.update_for_user("a@b.com", "")


@pytest.mark.asyncio
async def test_update_with_whitespace_only_raises_value_error(api_key_service):
    with pytest.raises(ValueError):
        await api_key_service.update_for_user("a@b.com", "   ")


@pytest.mark.asyncio
async def test_decrypt_with_changed_key_raises_corrupted(
    mocked_user_repository, env_vars
):
    env_vars("ENCRYPTION_KEY", "first-key")
    svc1 = ApiKeyService(mocked_user_repository)
    encrypted = svc1._encrypt("sk-test")

    env_vars("ENCRYPTION_KEY", "second-key-different")
    svc2 = ApiKeyService(mocked_user_repository)
    mocked_user_repository.get_by_email.return_value = User(
        email="a@b.com", password_hash="$", api_key=encrypted
    )
    with pytest.raises(ApiKeyCorrupted):
        await svc2.get_for_user("a@b.com")
