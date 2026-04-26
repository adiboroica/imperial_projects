"""Async OpenAI wrapper with retry policy, key rotation, and typed error translation."""

from __future__ import annotations

import asyncio
import logging
import os

from openai import APIConnectionError, APIStatusError, AsyncOpenAI, RateLimitError

from src.ai.prompts import (
    BRIDGE_WRITER_SYSTEM,
    GAMEBOOK_WRITER_SYSTEM,
    TEXT_EDITOR_SYSTEM,
)
from src.constants import MAX_RATE_LIMIT_ERRORS, REQ_FAILURE_TIMEOUT_SECS
from src.models.errors import (
    OpenAIConfigurationError,
    OpenAIRateLimit,
    OpenAIRequestError,
    OpenAIUnavailable,
)

logger = logging.getLogger(__name__)

DEFAULT_MODEL = os.getenv("OPENAI_MODEL", "gpt-5.4")


class APIKeyRoundRobinSelector:
    """Process-wide round-robin over the comma-separated `OPENAI_API_KEY` env var."""

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance.curr_index = 0
            cls._instance.keys = [
                k.strip() for k in os.getenv("OPENAI_API_KEY", "").split(",") if k.strip()
            ]
        return cls._instance

    def get_api_key(self) -> str:
        if not self.keys:
            raise OpenAIConfigurationError(
                "No OpenAI API keys configured. Set OPENAI_API_KEY (comma-separated for rotation)."
            )
        next_key = self.keys[self.curr_index]
        self.curr_index = (self.curr_index + 1) % len(self.keys)
        return next_key


class LLMClient:
    """Thin wrapper around `openai.AsyncOpenAI` that owns retry + key rotation."""

    def __init__(
        self,
        api_key: str | None = None,
        temperature: float = 0.5,
        max_tokens: int = 256,
    ) -> None:
        self.api_key = api_key
        self.temperature = temperature
        self.max_tokens = max_tokens
        self._round_robin = APIKeyRoundRobinSelector()
        self._current_key = self._next_api_key()
        self._client = AsyncOpenAI(api_key=self._current_key)

    def _next_api_key(self) -> str:
        if self.api_key is not None:
            return self.api_key
        return self._round_robin.get_api_key()

    def _get_client(self) -> AsyncOpenAI:
        key = self._next_api_key()
        if key != self._current_key:
            self._current_key = key
            self._client = AsyncOpenAI(api_key=self._current_key)
        return self._client

    async def complete(self, prompt: str) -> str:
        """One-shot completion using the gamebook-writer system instructions."""
        return await self._call_with_retry(self._do_complete, prompt)

    async def insert(self, prompt: str, suffix: str) -> str:
        """Generate text that bridges `prompt` to `suffix`."""
        return await self._call_with_retry(self._do_insert, prompt, suffix)

    async def edit(self, text_to_edit: str, instruction: str) -> str:
        """Apply `instruction` to `text_to_edit`."""
        return await self._call_with_retry(self._do_edit, text_to_edit, instruction)

    async def _call_with_retry(self, fn, *args, rate_limit_count: int = 0):
        try:
            return await fn(*args)
        except RateLimitError as exc:
            if rate_limit_count >= MAX_RATE_LIMIT_ERRORS:
                raise OpenAIRateLimit("OpenAI rate limit exceeded") from exc
            await asyncio.sleep(REQ_FAILURE_TIMEOUT_SECS)
            return await self._call_with_retry(
                fn, *args, rate_limit_count=rate_limit_count + 1
            )
        except APIStatusError as exc:
            if exc.status_code == 503:
                raise OpenAIUnavailable("OpenAI returned 503") from exc
            raise OpenAIRequestError(
                f"OpenAI returned {exc.status_code}: {exc.message}"
            ) from exc
        except APIConnectionError as exc:
            raise OpenAIUnavailable("OpenAI connection failed") from exc

    async def _do_complete(self, prompt: str) -> str:
        client = self._get_client()
        response = await client.responses.create(
            model=DEFAULT_MODEL,
            instructions=GAMEBOOK_WRITER_SYSTEM,
            input=prompt,
            temperature=self.temperature,
            max_output_tokens=self.max_tokens,
        )
        return response.output_text

    async def _do_insert(self, prompt: str, suffix: str) -> str:
        client = self._get_client()
        response = await client.responses.create(
            model=DEFAULT_MODEL,
            instructions=BRIDGE_WRITER_SYSTEM,
            input=f"Prefix:\n{prompt}\n\nSuffix:\n{suffix}\n\nWrite the connecting text:",
            temperature=self.temperature,
            max_output_tokens=self.max_tokens,
        )
        return response.output_text

    async def _do_edit(self, text_to_edit: str, instruction: str) -> str:
        client = self._get_client()
        response = await client.responses.create(
            model=DEFAULT_MODEL,
            instructions=TEXT_EDITOR_SYSTEM,
            input=f"Text: {text_to_edit}\n\nInstruction: {instruction}",
            temperature=self.temperature,
        )
        return response.output_text
