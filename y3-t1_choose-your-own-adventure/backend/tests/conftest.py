"""Shared pytest fixtures.

Lives at the test root so every layer (unit, integration, architecture) can
import from it without a per-folder duplicate.
"""

from __future__ import annotations

import asyncio
from collections.abc import Iterator
from typing import Any
from unittest.mock import AsyncMock, MagicMock

import pytest


@pytest.fixture(scope="session")
def event_loop() -> Iterator[asyncio.AbstractEventLoop]:
    """One shared event loop for the test session.

    Required by pytest-asyncio when fixtures span multiple tests.
    """
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def mocked_openai() -> MagicMock:
    """A scriptable replacement for `openai.AsyncOpenAI`.

    Test bodies set ``mocked_openai.responses.create.return_value = ...`` to
    define the canned response for the upcoming call.
    """
    client = MagicMock()
    client.responses = MagicMock()
    client.responses.create = AsyncMock()
    return client


@pytest.fixture
def mocked_user_repository() -> AsyncMock:
    """An async mock of `UserRepository` for service-layer tests."""
    repo = AsyncMock()
    return repo


@pytest.fixture
def mocked_session_repository() -> AsyncMock:
    """An async mock of `SessionRepository` for service-layer tests."""
    repo = AsyncMock()
    return repo


@pytest.fixture
def mocked_story_repository() -> AsyncMock:
    """An async mock of `StoryRepository` for service-layer tests."""
    repo = AsyncMock()
    return repo


@pytest.fixture
def mocked_llm_client() -> AsyncMock:
    """An async mock of `LLMClient` for `TextGenerator` and `GenerationService` tests."""
    client = AsyncMock()
    return client


@pytest.fixture
def env_vars(monkeypatch: pytest.MonkeyPatch) -> Any:
    """Helper to set/clear env vars within a single test.

    Usage:
        def test_foo(env_vars):
            env_vars("OPENAI_API_KEY", "sk-test")
    """

    def _set(name: str, value: str | None) -> None:
        if value is None:
            monkeypatch.delenv(name, raising=False)
        else:
            monkeypatch.setenv(name, value)

    return _set
