"""`/auth/*` HTTP surface — signup, login, logout, session lookup."""

from __future__ import annotations

import logging
import os

from fastapi import APIRouter, Depends, HTTPException, Request, Response
from slowapi import Limiter
from slowapi.util import get_remote_address

from src.dependencies import COOKIE_NAME, get_auth_service, get_current_user
from src.models.auth import LoginRequest, SignupRequest, User, UserResponse
from src.models.errors import EmailAlreadyExists, InvalidCredentials
from src.services import AuthService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth")
limiter = Limiter(key_func=get_remote_address)


def _cookie_kwargs() -> dict:
    if os.getenv("DEV", "").lower() in ("true", "1", "yes"):
        return {"samesite": "lax", "secure": False, "httponly": True}
    return {"samesite": "none", "secure": True, "httponly": True}


@router.post("/signup", response_model=UserResponse, status_code=201)
@limiter.limit("5/minute")
async def signup(
    request: Request,
    body: SignupRequest,
    response: Response,
    auth: AuthService = Depends(get_auth_service),
) -> UserResponse:
    try:
        user, session = await auth.signup(body.email, body.password)
    except EmailAlreadyExists as exc:
        raise HTTPException(status_code=409, detail="Email already registered") from exc
    response.set_cookie(COOKIE_NAME, session.id, **_cookie_kwargs())
    return UserResponse(email=user.email)


@router.post("/login", response_model=UserResponse)
@limiter.limit("10/minute")
async def login(
    request: Request,
    body: LoginRequest,
    response: Response,
    auth: AuthService = Depends(get_auth_service),
) -> UserResponse:
    try:
        user, session = await auth.login(body.email, body.password)
    except InvalidCredentials as exc:
        raise HTTPException(status_code=401, detail="Invalid credentials") from exc
    response.set_cookie(COOKIE_NAME, session.id, **_cookie_kwargs())
    return UserResponse(email=user.email)


@router.post("/logout")
async def logout(
    request: Request,
    response: Response,
    auth: AuthService = Depends(get_auth_service),
) -> dict:
    session_id = request.cookies.get(COOKIE_NAME)
    await auth.logout(session_id)
    response.delete_cookie(COOKIE_NAME)
    return {}


@router.get("/session", response_model=UserResponse)
async def session(user: User = Depends(get_current_user)) -> UserResponse:
    return UserResponse(email=user.email)
