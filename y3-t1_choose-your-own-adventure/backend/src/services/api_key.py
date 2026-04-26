"""ApiKeyService — fetch and rotate the user's OpenAI API key, encrypted at rest."""

from __future__ import annotations

import base64
import hashlib
import logging
import os

from cryptography.fernet import Fernet, InvalidToken

from src.models.errors import ApiKeyCorrupted, UserNotFound
from src.repositories import UserRepository

logger = logging.getLogger(__name__)


class ApiKeyService:
    """Owns symmetric encryption for stored API keys; nothing else sees the cipher."""

    def __init__(self, user_repository: UserRepository) -> None:
        self._users = user_repository
        self._fernet: Fernet | None = None

    def _get_fernet(self) -> Fernet:
        if self._fernet is None:
            key = os.getenv("ENCRYPTION_KEY", "dev-only-not-secure-change-me-now")
            digest = hashlib.sha256(key.encode()).digest()
            self._fernet = Fernet(base64.urlsafe_b64encode(digest))
        return self._fernet

    def _encrypt(self, plaintext: str) -> str:
        if not plaintext:
            return ""
        return self._get_fernet().encrypt(plaintext.encode()).decode()

    def _decrypt(self, ciphertext: str | None) -> str | None:
        if not ciphertext:
            return None
        try:
            return self._get_fernet().decrypt(ciphertext.encode()).decode()
        except (InvalidToken, ValueError) as exc:
            raise ApiKeyCorrupted(
                "Stored API key cannot be decrypted with the current ENCRYPTION_KEY"
            ) from exc

    async def get_for_user(self, user_email: str) -> str | None:
        user = await self._users.get_by_email(user_email)
        if user is None:
            raise UserNotFound(user_email)
        if user.api_key is None:
            return None
        return self._decrypt(user.api_key)

    async def update_for_user(self, user_email: str, plaintext_key: str) -> None:
        if not plaintext_key or not plaintext_key.strip():
            raise ValueError("API key must be a non-empty string")
        encrypted = self._encrypt(plaintext_key)
        await self._users.set_api_key(user_email, encrypted)
        logger.info("Updated API key for %s", user_email)
