"""Auth model unit tests."""

from __future__ import annotations

from datetime import datetime, timedelta, timezone

import pytest
from pydantic import ValidationError

from src.models.auth import LoginRequest, Session, SignupRequest, User, UserResponse


# --- Core Functionality ---


def test_login_request_accepts_valid_email_and_password():
    body = LoginRequest(email="user@example.com", password="anything")
    assert body.email == "user@example.com"


def test_signup_request_enforces_minimum_password_length():
    body = SignupRequest(email="user@example.com", password="longenough")
    assert body.password == "longenough"


def test_user_round_trip_with_aliases():
    user = User(email="a@b.com", password_hash="$2b$12$abc", api_key=None)
    dumped = user.model_dump(by_alias=True)
    assert dumped["passwordHash"] == "$2b$12$abc"
    assert dumped["apiKey"] is None
    restored = User.model_validate(dumped)
    assert restored == user


def test_session_id_is_uuid_v4():
    import uuid

    s = Session(
        user_email="a@b.com",
        expires_at=datetime.now(timezone.utc) + timedelta(days=1),
    )
    # `id` defaults to a UUID v4 string.
    parsed = uuid.UUID(s.id, version=4)
    assert str(parsed) == s.id


def test_user_response_excludes_internal_fields():
    user = User(email="a@b.com", password_hash="$2b$12$abc", api_key="secret")
    response = UserResponse(email=user.email)
    dumped = response.model_dump()
    assert "passwordHash" not in dumped
    assert "apiKey" not in dumped


# --- Edge Cases ---


def test_login_request_rejects_malformed_email():
    with pytest.raises(ValidationError):
        LoginRequest(email="not-an-email", password="x")


def test_signup_request_rejects_short_password():
    with pytest.raises(ValidationError):
        SignupRequest(email="user@example.com", password="short")


def test_session_rejects_expires_before_created():
    now = datetime.now(timezone.utc)
    with pytest.raises(ValidationError):
        Session(
            user_email="a@b.com",
            created_at=now,
            expires_at=now - timedelta(seconds=1),
        )
