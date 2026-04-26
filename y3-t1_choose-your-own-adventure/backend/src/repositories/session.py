"""SessionRepository — the `sessions` collection."""

from __future__ import annotations

import logging
from datetime import datetime, timezone

from motor.motor_asyncio import AsyncIOMotorDatabase
from pymongo.errors import PyMongoError

from src.models.auth import Session
from src.models.errors import RepositoryError

logger = logging.getLogger(__name__)


class SessionRepository:
    """Session records keyed by UUID with a TTL index on `expiresAt`."""

    COLLECTION = "sessions"

    def __init__(self, db: AsyncIOMotorDatabase) -> None:
        self._db = db

    @property
    def _coll(self):
        return self._db[self.COLLECTION]

    async def ensure_indexes(self) -> None:
        """Create the TTL index on `expiresAt` plus a helper index on `userEmail`."""
        await self._coll.create_index("expiresAt", expireAfterSeconds=0)
        await self._coll.create_index("userEmail")

    async def create(self, session: Session) -> Session:
        try:
            await self._coll.insert_one(session.model_dump(by_alias=True))
        except PyMongoError as exc:
            logger.exception("SessionRepository.create failed for %s", session.user_email)
            raise RepositoryError("Failed to create session") from exc
        return session

    async def get_by_id(self, session_id: str) -> Session | None:
        try:
            doc = await self._coll.find_one({"_id": session_id})
        except PyMongoError as exc:
            logger.exception("SessionRepository.get_by_id failed for %s", session_id)
            raise RepositoryError("Failed to load session") from exc
        if doc is None:
            return None
        return Session.model_validate(doc)

    async def delete(self, session_id: str) -> None:
        try:
            await self._coll.delete_one({"_id": session_id})
        except PyMongoError as exc:
            logger.exception("SessionRepository.delete failed for %s", session_id)
            raise RepositoryError("Failed to delete session") from exc

    async def is_expired(self, session: Session) -> bool:
        """Belt-and-braces check (TTL is asynchronous so we also enforce here)."""
        return session.expires_at <= datetime.now(timezone.utc)
