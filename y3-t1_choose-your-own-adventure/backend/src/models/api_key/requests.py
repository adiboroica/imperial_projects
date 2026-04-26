"""`PUT /api-key` request shape."""

from __future__ import annotations

from pydantic import BaseModel, Field, field_validator


class ApiKeyRequest(BaseModel):
    """Plain-string wire shape; encryption happens inside `ApiKeyService`."""

    api_key: str = Field(alias="apiKey")

    model_config = {"populate_by_name": True}

    @field_validator("api_key")
    @classmethod
    def _strip_and_require_non_empty(cls, value: str) -> str:
        stripped = value.strip()
        if not stripped:
            raise ValueError("apiKey must be a non-empty string")
        return stripped
