"""API-key router integration tests."""

from __future__ import annotations

import pytest


@pytest.mark.asyncio
async def test_get_returns_null_when_no_key_set(signed_up_client):
    response = await signed_up_client.get("/api-key")
    assert response.status_code == 200
    assert response.json() == {"apiKey": None}


@pytest.mark.asyncio
async def test_put_stores_encrypted_key_and_get_returns_decrypted(signed_up_client):
    response = await signed_up_client.put(
        "/api-key", json={"apiKey": "sk-live-12345"}
    )
    assert response.status_code == 200
    fetched = await signed_up_client.get("/api-key")
    assert fetched.status_code == 200
    assert fetched.json()["apiKey"] == "sk-live-12345"


@pytest.mark.asyncio
async def test_put_with_empty_string_returns_422(signed_up_client):
    response = await signed_up_client.put("/api-key", json={"apiKey": ""})
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_get_unauthenticated_returns_401(client):
    response = await client.get("/api-key")
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_put_unauthenticated_returns_401(client):
    response = await client.put("/api-key", json={"apiKey": "sk-test"})
    assert response.status_code == 401
