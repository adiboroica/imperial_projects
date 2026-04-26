"""WSEnvelope — the universal frame format for every `/ws` message."""

from __future__ import annotations

from typing import Any
from uuid import UUID

from pydantic import BaseModel, Field, field_validator


class WSEnvelope(BaseModel):
    """Carries `requestId`, `type`, and a typed `payload`.

    The router validates the envelope first, then validates the payload using
    the per-type model from ``CLIENT_PAYLOAD_TYPES``. An unknown ``type`` or a
    payload that fails validation closes the socket with code 1003.
    """

    request_id: str = Field(alias="requestId")
    type: str
    payload: dict[str, Any] = Field(default_factory=dict)

    model_config = {"populate_by_name": True}

    @field_validator("request_id")
    @classmethod
    def _validate_uuid_v4(cls, value: str) -> str:
        try:
            UUID(value, version=4)
        except (ValueError, AttributeError, TypeError) as exc:
            raise ValueError("requestId must be a valid UUID v4") from exc
        return value
