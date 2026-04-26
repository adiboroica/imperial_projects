"""AuthService unit tests."""

from __future__ import annotations

from datetime import datetime, timedelta, timezone

import pytest

from src.models.auth import Session, User
from src.models.errors import (
    EmailAlreadyExists,
    InvalidCredentials,
    SessionExpired,
    SessionNotFound,
    Unauthenticated,
    UserNotFound,
)
from src.services.auth import SESSION_TTL, AuthService


@pytest.fixture
def auth_service(mocked_user_repository, mocked_session_repository):
    return AuthService(mocked_user_repository, mocked_session_repository)


def _hashed(password: str) -> str:
    import bcrypt

    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


# --- Core Functionality ---


@pytest.mark.asyncio
async def test_signup_creates_user_and_session(
    auth_service, mocked_user_repository, mocked_session_repository
):
    mocked_user_repository.get_by_email.return_value = None
    user, session = await auth_service.signup("a@b.com", "password123")
    assert user.email == "a@b.com"
    assert user.password_hash != "password123"
    assert session.user_email == "a@b.com"
    mocked_user_repository.create.assert_awaited_once()
    mocked_session_repository.create.assert_awaited_once()


@pytest.mark.asyncio
async def test_login_with_correct_password_opens_session(
    auth_service, mocked_user_repository, mocked_session_repository
):
    mocked_user_repository.get_by_email.return_value = User(
        email="a@b.com", password_hash=_hashed("password")
    )
    user, session = await auth_service.login("a@b.com", "password")
    assert user.email == "a@b.com"
    assert session.user_email == "a@b.com"
    mocked_session_repository.create.assert_awaited_once()


@pytest.mark.asyncio
async def test_logout_deletes_session(
    auth_service, mocked_session_repository
):
    await auth_service.logout("session-id-1")
    mocked_session_repository.delete.assert_awaited_once_with("session-id-1")


@pytest.mark.asyncio
async def test_logout_with_no_session_id_is_noop(
    auth_service, mocked_session_repository
):
    await auth_service.logout(None)
    mocked_session_repository.delete.assert_not_awaited()


@pytest.mark.asyncio
async def test_validate_session_returns_user(
    auth_service, mocked_user_repository, mocked_session_repository
):
    now = datetime.now(timezone.utc)
    mocked_session_repository.get_by_id.return_value = Session(
        user_email="a@b.com", expires_at=now + timedelta(days=1)
    )
    mocked_session_repository.is_expired.return_value = False
    mocked_user_repository.get_by_email.return_value = User(
        email="a@b.com", password_hash="$"
    )
    user = await auth_service.validate_session("session-id-1")
    assert user.email == "a@b.com"


@pytest.mark.asyncio
async def test_session_ttl_is_seven_days(auth_service):
    assert SESSION_TTL == timedelta(days=7)


# --- Edge Cases ---


@pytest.mark.asyncio
async def test_signup_with_existing_email_raises(
    auth_service, mocked_user_repository
):
    mocked_user_repository.get_by_email.return_value = User(
        email="a@b.com", password_hash="$"
    )
    with pytest.raises(EmailAlreadyExists):
        await auth_service.signup("a@b.com", "password123")


@pytest.mark.asyncio
async def test_login_with_wrong_password_raises(
    auth_service, mocked_user_repository
):
    mocked_user_repository.get_by_email.return_value = User(
        email="a@b.com", password_hash=_hashed("correct")
    )
    with pytest.raises(InvalidCredentials):
        await auth_service.login("a@b.com", "wrong")


@pytest.mark.asyncio
async def test_login_with_unknown_email_raises(
    auth_service, mocked_user_repository
):
    mocked_user_repository.get_by_email.return_value = None
    with pytest.raises(InvalidCredentials):
        await auth_service.login("unknown@b.com", "anything")


@pytest.mark.asyncio
async def test_validate_session_no_cookie_raises_unauthenticated(auth_service):
    with pytest.raises(Unauthenticated):
        await auth_service.validate_session(None)


@pytest.mark.asyncio
async def test_validate_session_unknown_id_raises_session_not_found(
    auth_service, mocked_session_repository
):
    mocked_session_repository.get_by_id.return_value = None
    with pytest.raises(SessionNotFound):
        await auth_service.validate_session("missing-id")


@pytest.mark.asyncio
async def test_validate_session_expired_raises_and_deletes(
    auth_service, mocked_session_repository
):
    now = datetime.now(timezone.utc)
    mocked_session_repository.get_by_id.return_value = Session(
        user_email="a@b.com", expires_at=now + timedelta(seconds=1)
    )
    mocked_session_repository.is_expired.return_value = True
    with pytest.raises(SessionExpired):
        await auth_service.validate_session("expired-id")
    mocked_session_repository.delete.assert_awaited_once_with("expired-id")


@pytest.mark.asyncio
async def test_validate_session_user_gone_raises_user_not_found(
    auth_service, mocked_user_repository, mocked_session_repository
):
    now = datetime.now(timezone.utc)
    mocked_session_repository.get_by_id.return_value = Session(
        user_email="a@b.com", expires_at=now + timedelta(days=1)
    )
    mocked_session_repository.is_expired.return_value = False
    mocked_user_repository.get_by_email.return_value = None
    with pytest.raises(UserNotFound):
        await auth_service.validate_session("session-id-1")
