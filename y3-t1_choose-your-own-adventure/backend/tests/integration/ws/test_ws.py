"""WebSocket router integration tests using FastAPI's `TestClient.websocket_connect`.

Note: AsyncClient doesn't expose a WebSocket helper; we use the synchronous
`fastapi.testclient.TestClient` for these.
"""

from __future__ import annotations

from uuid import uuid4

import pytest
from fastapi.testclient import TestClient
from starlette.websockets import WebSocketDisconnect


def _envelope(msg_type: str, payload: dict) -> dict:
    return {
        "requestId": str(uuid4()),
        "type": msg_type,
        "payload": payload,
    }


@pytest.fixture
def sync_test_client(overridden_app):
    return TestClient(overridden_app)


@pytest.fixture
def session_cookie(sync_test_client):
    """Sign up via REST so the cookie is set on the client; reuse for WS."""
    response = sync_test_client.post(
        "/auth/signup",
        json={"email": "ws-tester@example.com", "password": "password123"},
    )
    assert response.status_code == 201, response.text
    return response.cookies.get("cyoa_session")


def test_connect_with_no_cookie_closes_4001(sync_test_client):
    with pytest.raises(WebSocketDisconnect) as exc_info:
        with sync_test_client.websocket_connect("/ws") as ws:
            ws.receive_json()
    assert exc_info.value.code == 4001


def test_unknown_message_type_closes_1003(sync_test_client, session_cookie):
    with pytest.raises(WebSocketDisconnect) as exc_info:
        with sync_test_client.websocket_connect("/ws") as ws:
            ws.send_json(_envelope("notARealType", {}))
            ws.receive_json()  # connection closes before any frame
    assert exc_info.value.code == 1003


def test_payload_validation_failure_closes_1003(sync_test_client, session_cookie):
    with pytest.raises(WebSocketDisconnect) as exc_info:
        with sync_test_client.websocket_connect("/ws") as ws:
            # initialStory requires `genre`, `attributes`, `temperature`.
            ws.send_json(_envelope("initialStory", {}))
            ws.receive_json()
    assert exc_info.value.code == 1003


def test_envelope_missing_request_id_closes_1003(sync_test_client, session_cookie):
    with pytest.raises(WebSocketDisconnect) as exc_info:
        with sync_test_client.websocket_connect("/ws") as ws:
            ws.send_json({"type": "initialStory", "payload": {"genre": "x"}})
            ws.receive_json()
    assert exc_info.value.code == 1003


def test_origin_mismatch_closes_4003(sync_test_client, session_cookie):
    # The origin header must match APP_URL; default APP_URL is http://localhost:3000.
    with pytest.raises(WebSocketDisconnect) as exc_info:
        with sync_test_client.websocket_connect(
            "/ws",
            headers={"origin": "http://evil.example.com"},
        ) as ws:
            ws.receive_json()
    assert exc_info.value.code == 4003
