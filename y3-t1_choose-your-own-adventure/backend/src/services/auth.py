"""AuthService — signup, login, logout, session validation."""

from __future__ import annotations

import logging
from datetime import datetime, timedelta, timezone

import bcrypt

from src.models.auth import Session, User
from src.models.errors import (
    EmailAlreadyExists,
    InvalidCredentials,
    SessionExpired,
    SessionNotFound,
    Unauthenticated,
    UserNotFound,
)
from src.repositories import SessionRepository, UserRepository

logger = logging.getLogger(__name__)

SESSION_TTL = timedelta(days=7)


class AuthService:
    """Owns password hashing and the session lifecycle."""

    def __init__(
        self,
        user_repository: UserRepository,
        session_repository: SessionRepository,
    ) -> None:
        self._users = user_repository
        self._sessions = session_repository

    # ---------- Password handling (bcrypt lives here) ----------

    @staticmethod
    def _hash_password(plaintext: str) -> str:
        return bcrypt.hashpw(plaintext.encode(), bcrypt.gensalt()).decode()

    @staticmethod
    def _verify_password(plaintext: str, hashed: str) -> bool:
        try:
            return bcrypt.checkpw(plaintext.encode(), hashed.encode())
        except (ValueError, TypeError):
            return False

    # ---------- Signup / login / logout ----------

    async def signup(self, email: str, password: str) -> tuple[User, Session]:
        existing = await self._users.get_by_email(email)
        if existing is not None:
            raise EmailAlreadyExists(email)

        user = User(email=email, password_hash=self._hash_password(password))
        await self._users.create(user)
        session = await self._open_session(email)
        logger.info("Signup succeeded for %s", email)
        return user, session

    async def login(self, email: str, password: str) -> tuple[User, Session]:
        user = await self._users.get_by_email(email)
        if user is None or not self._verify_password(password, user.password_hash):
            logger.info("Login failed for %s", email)
            raise InvalidCredentials("Email or password is incorrect")
        session = await self._open_session(email)
        logger.info("Login succeeded for %s", email)
        return user, session

    async def logout(self, session_id: str | None) -> None:
        if not session_id:
            return
        await self._sessions.delete(session_id)

    # ---------- Session validation ----------

    async def validate_session(self, session_id: str | None) -> User:
        if not session_id:
            raise Unauthenticated("No session cookie")
        session = await self._sessions.get_by_id(session_id)
        if session is None:
            raise SessionNotFound(session_id)
        if await self._sessions.is_expired(session):
            await self._sessions.delete(session_id)
            raise SessionExpired("Session has expired")
        user = await self._users.get_by_email(session.user_email)
        if user is None:
            await self._sessions.delete(session_id)
            raise UserNotFound(session.user_email)
        return user

    # ---------- Internals ----------

    async def _open_session(self, email: str) -> Session:
        now = datetime.now(timezone.utc)
        session = Session(user_email=email, expires_at=now + SESSION_TTL)
        await self._sessions.create(session)
        return session
