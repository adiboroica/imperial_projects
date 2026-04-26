"""HTTP response shapes for the `/auth/*` routes."""

from __future__ import annotations

from pydantic import BaseModel


class UserResponse(BaseModel):
    """Safe projection of a `User` for wire output. Never includes `passwordHash` or `apiKey`."""

    email: str
