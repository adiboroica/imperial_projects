"""API-key model unit tests."""

from __future__ import annotations

import pytest
from pydantic import ValidationError

from src.models.api_key import ApiKeyRequest, ApiKeyResponse


# --- Core Functionality ---


def test_api_key_request_accepts_non_empty_string():
    body = ApiKeyRequest(api_key="sk-test-12345")
    assert body.api_key == "sk-test-12345"


def test_api_key_request_strips_surrounding_whitespace():
    body = ApiKeyRequest(api_key="  sk-test-12345  ")
    assert body.api_key == "sk-test-12345"


def test_api_key_response_serialises_with_alias():
    response = ApiKeyResponse(api_key="sk-test-12345")
    dumped = response.model_dump(by_alias=True)
    assert dumped["apiKey"] == "sk-test-12345"


def test_api_key_response_accepts_null():
    response = ApiKeyResponse(api_key=None)
    assert response.api_key is None


# --- Edge Cases ---


def test_api_key_request_rejects_empty_string():
    with pytest.raises(ValidationError):
        ApiKeyRequest(api_key="")


def test_api_key_request_rejects_whitespace_only():
    with pytest.raises(ValidationError):
        ApiKeyRequest(api_key="   ")
