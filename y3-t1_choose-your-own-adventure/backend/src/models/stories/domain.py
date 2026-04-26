"""Story — the in-memory shape services and repositories manipulate."""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from pydantic import BaseModel, Field, field_validator

from src.models.graph import GamebookGraph


def _coerce_utc(value: Any) -> Any:
    """Treat naive datetimes (from MongoDB BSON) as UTC-aware."""
    if isinstance(value, datetime) and value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value


class Story(BaseModel):
    """A story document. The graph is embedded directly; no cross-collection join."""

    id: str = Field(alias="_id")
    user_email: str = Field(alias="userEmail")
    name: str = "Story"
    graph: GamebookGraph = Field(default_factory=GamebookGraph)
    created_at: datetime = Field(
        alias="createdAt",
        default_factory=lambda: datetime.now(timezone.utc),
    )
    updated_at: datetime = Field(
        alias="updatedAt",
        default_factory=lambda: datetime.now(timezone.utc),
    )

    model_config = {"populate_by_name": True}

    @field_validator("created_at", "updated_at", mode="before")
    @classmethod
    def _ensure_tz_aware(cls, value: Any) -> Any:
        return _coerce_utc(value)
