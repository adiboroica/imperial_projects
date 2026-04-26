"""UserRepository — the `users` collection."""

from __future__ import annotations

import logging

from motor.motor_asyncio import AsyncIOMotorDatabase
from pymongo.errors import DuplicateKeyError, PyMongoError

from src.models.auth import User
from src.models.errors import EmailAlreadyExists, RepositoryError, UserNotFound

logger = logging.getLogger(__name__)


class UserRepository:
    """Account records: email (unique), encrypted password hash, optional encrypted API key."""

    COLLECTION = "users"

    def __init__(self, db: AsyncIOMotorDatabase) -> None:
        self._db = db

    @property
    def _coll(self):
        return self._db[self.COLLECTION]

    async def ensure_indexes(self) -> None:
        """Create the unique-email index. Idempotent."""
        await self._coll.create_index("email", unique=True)

    async def get_by_email(self, email: str) -> User | None:
        try:
            doc = await self._coll.find_one({"email": email})
        except PyMongoError as exc:
            logger.exception("UserRepository.get_by_email failed for %s", email)
            raise RepositoryError("Failed to load user") from exc
        if doc is None:
            return None
        return User.model_validate(doc)

    async def create(self, user: User) -> User:
        """Insert a new user. Raises EmailAlreadyExists on duplicate email."""
        try:
            await self._coll.insert_one(user.model_dump(by_alias=True))
        except DuplicateKeyError as exc:
            raise EmailAlreadyExists(user.email) from exc
        except PyMongoError as exc:
            logger.exception("UserRepository.create failed for %s", user.email)
            raise RepositoryError("Failed to create user") from exc
        return user

    async def set_api_key(self, email: str, encrypted_api_key: str | None) -> None:
        """Store an encrypted API key (or `None` to clear). Raises `UserNotFound` if no match."""
        try:
            result = await self._coll.update_one(
                {"email": email},
                {"$set": {"apiKey": encrypted_api_key}},
            )
        except PyMongoError as exc:
            logger.exception("UserRepository.set_api_key failed for %s", email)
            raise RepositoryError("Failed to update api key") from exc
        if result.matched_count == 0:
            raise UserNotFound(email)
