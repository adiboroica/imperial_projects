"""Auth router integration tests."""

from __future__ import annotations

import pytest


@pytest.mark.asyncio
async def test_signup_creates_account_and_sets_cookie(client):
    response = await client.post(
        "/auth/signup",
        json={"email": "new@example.com", "password": "password123"},
    )
    assert response.status_code == 201
    assert response.json()["email"] == "new@example.com"
    assert "cyoa_session" in response.cookies


@pytest.mark.asyncio
async def test_signup_with_existing_email_returns_409(client):
    body = {"email": "dup@example.com", "password": "password123"}
    await client.post("/auth/signup", json=body)
    response = await client.post("/auth/signup", json=body)
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_signup_with_short_password_returns_422(client):
    response = await client.post(
        "/auth/signup",
        json={"email": "x@example.com", "password": "short"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_signup_with_malformed_email_returns_422(client):
    response = await client.post(
        "/auth/signup",
        json={"email": "not-an-email", "password": "password123"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_login_with_correct_credentials_returns_200(client):
    await client.post(
        "/auth/signup",
        json={"email": "live@example.com", "password": "password123"},
    )
    client.cookies.clear()
    response = await client.post(
        "/auth/login",
        json={"email": "live@example.com", "password": "password123"},
    )
    assert response.status_code == 200
    assert response.json()["email"] == "live@example.com"


@pytest.mark.asyncio
async def test_login_with_wrong_password_returns_401(client):
    await client.post(
        "/auth/signup",
        json={"email": "wp@example.com", "password": "password123"},
    )
    client.cookies.clear()
    response = await client.post(
        "/auth/login",
        json={"email": "wp@example.com", "password": "WRONG"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_login_with_unknown_email_returns_401(client):
    response = await client.post(
        "/auth/login",
        json={"email": "ghost@example.com", "password": "password123"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_session_endpoint_returns_user_when_authenticated(signed_up_client):
    response = await signed_up_client.get("/auth/session")
    assert response.status_code == 200
    assert response.json()["email"] == "tester@example.com"


@pytest.mark.asyncio
async def test_session_endpoint_without_cookie_returns_401(client):
    response = await client.get("/auth/session")
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_logout_clears_session(signed_up_client):
    response = await signed_up_client.post("/auth/logout")
    assert response.status_code == 200
    # After logout the session cookie should no longer authenticate.
    after = await signed_up_client.get("/auth/session")
    assert after.status_code == 401
