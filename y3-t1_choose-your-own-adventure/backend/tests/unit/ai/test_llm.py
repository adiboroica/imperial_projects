"""LLMClient unit tests with the openai SDK mocked."""

from __future__ import annotations

from types import SimpleNamespace
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from openai import APIConnectionError, APIStatusError, RateLimitError

from src.ai.llm import APIKeyRoundRobinSelector, LLMClient
from src.models.errors import (
    OpenAIConfigurationError,
    OpenAIRateLimit,
    OpenAIRequestError,
    OpenAIUnavailable,
)


@pytest.fixture(autouse=True)
def reset_round_robin_singleton():
    """Reset the module-level singleton between tests."""
    APIKeyRoundRobinSelector._instance = None
    yield
    APIKeyRoundRobinSelector._instance = None


def _mock_response(text: str) -> MagicMock:
    return MagicMock(output_text=text)


def _fake_response(code: int) -> SimpleNamespace:
    """Stub object shaped for the OpenAI SDK exception base class — needs
    `request`, `status_code`, and `headers` (for `request_id` extraction)."""
    return SimpleNamespace(
        status_code=code,
        request=SimpleNamespace(method="POST", url="https://api.openai.com/v1"),
        headers={},
    )


def _make_status_error(code: int) -> APIStatusError:
    return APIStatusError(
        message=f"status {code}",
        response=_fake_response(code),
        body=None,
    )


# --- Core Functionality ---


@pytest.mark.asyncio
async def test_complete_returns_response_text(env_vars):
    env_vars("OPENAI_API_KEY", "sk-test")
    client = LLMClient(temperature=0.5)
    fake = AsyncMock()
    fake.responses.create = AsyncMock(return_value=_mock_response("hello"))
    with patch.object(client, "_get_client", return_value=fake):
        result = await client.complete("prompt")
    assert result == "hello"


@pytest.mark.asyncio
async def test_user_supplied_key_overrides_pool(env_vars):
    env_vars("OPENAI_API_KEY", "sk-pool")
    client = LLMClient(api_key="sk-user")
    assert client._next_api_key() == "sk-user"


@pytest.mark.asyncio
async def test_pool_rotates_round_robin(env_vars):
    env_vars("OPENAI_API_KEY", "sk-1,sk-2,sk-3")
    selector = APIKeyRoundRobinSelector()
    keys = [selector.get_api_key() for _ in range(6)]
    assert keys == ["sk-1", "sk-2", "sk-3", "sk-1", "sk-2", "sk-3"]


# --- Edge Cases ---


@pytest.mark.asyncio
async def test_empty_pool_and_no_user_key_raises_configuration_error(env_vars):
    env_vars("OPENAI_API_KEY", "")
    selector = APIKeyRoundRobinSelector()
    with pytest.raises(OpenAIConfigurationError):
        selector.get_api_key()


@pytest.mark.asyncio
async def test_503_translated_to_unavailable(env_vars):
    env_vars("OPENAI_API_KEY", "sk-test")
    client = LLMClient()
    fake = AsyncMock()
    fake.responses.create = AsyncMock(side_effect=_make_status_error(503))
    with patch.object(client, "_get_client", return_value=fake):
        with pytest.raises(OpenAIUnavailable):
            await client.complete("prompt")


@pytest.mark.asyncio
async def test_400_translated_to_request_error(env_vars):
    env_vars("OPENAI_API_KEY", "sk-test")
    client = LLMClient()
    fake = AsyncMock()
    fake.responses.create = AsyncMock(side_effect=_make_status_error(400))
    with patch.object(client, "_get_client", return_value=fake):
        with pytest.raises(OpenAIRequestError):
            await client.complete("prompt")


@pytest.mark.asyncio
async def test_connection_error_translated_to_unavailable(env_vars):
    env_vars("OPENAI_API_KEY", "sk-test")
    client = LLMClient()
    fake = AsyncMock()
    fake.responses.create = AsyncMock(
        side_effect=APIConnectionError(request=SimpleNamespace())
    )
    with patch.object(client, "_get_client", return_value=fake):
        with pytest.raises(OpenAIUnavailable):
            await client.complete("prompt")


@pytest.mark.asyncio
async def test_rate_limit_eventually_raises_after_retries(env_vars):
    env_vars("OPENAI_API_KEY", "sk-test")
    client = LLMClient()
    fake = AsyncMock()

    rate_limit = RateLimitError(
        message="rate", response=_fake_response(429), body=None
    )
    fake.responses.create = AsyncMock(side_effect=rate_limit)
    # Patch sleep to keep tests fast.
    with (
        patch.object(client, "_get_client", return_value=fake),
        patch("src.ai.llm.asyncio.sleep", AsyncMock()),
    ):
        with pytest.raises(OpenAIRateLimit):
            await client.complete("prompt")
