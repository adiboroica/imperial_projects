"""User and Session — the in-memory shapes the auth layer manipulates."""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any
from uuid import uuid4

from pydantic import BaseModel, Field, field_validator, model_validator


def _coerce_utc(value: Any) -> Any:
    """Treat naive datetimes (e.g. from MongoDB BSON) as UTC."""
    if isinstance(value, datetime) and value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value


class User(BaseModel):
    """Account record. Stored in the `users` collection."""

    email: str
    password_hash: str = Field(alias="passwordHash")
    api_key: str | None = Field(default=None, alias="apiKey")  # encrypted at rest

    model_config = {"populate_by_name": True}


class Session(BaseModel):
    """Session record. Stored in the `sessions` collection with TTL on `expires_at`."""

    id: str = Field(alias="_id", default_factory=lambda: str(uuid4()))
    user_email: str = Field(alias="userEmail")
    created_at: datetime = Field(
        alias="createdAt",
        default_factory=lambda: datetime.now(timezone.utc),
    )
    expires_at: datetime = Field(alias="expiresAt")

    model_config = {"populate_by_name": True}

    @field_validator("created_at", "expires_at", mode="before")
    @classmethod
    def _ensure_tz_aware(cls, value: Any) -> Any:
        return _coerce_utc(value)

    @model_validator(mode="after")
    def _expires_after_created(self) -> "Session":
        if self.expires_at <= self.created_at:
            raise ValueError("expiresAt must be after createdAt")
        return self
