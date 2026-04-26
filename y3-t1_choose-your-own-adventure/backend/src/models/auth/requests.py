"""HTTP request shapes for the `/auth/*` routes."""

from __future__ import annotations

from pydantic import BaseModel, EmailStr, Field


class LoginRequest(BaseModel):
    """`POST /auth/login` body."""

    email: EmailStr
    password: str = Field(min_length=1)


class SignupRequest(BaseModel):
    """`POST /auth/signup` body."""

    email: EmailStr
    password: str = Field(min_length=8)
