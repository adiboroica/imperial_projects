"""`GET /api-key` response shape."""

from __future__ import annotations

from pydantic import BaseModel, Field


class ApiKeyResponse(BaseModel):
    """`null` when the user has no key stored; never raises a 404."""

    api_key: str | None = Field(alias="apiKey")

    model_config = {"populate_by_name": True}
