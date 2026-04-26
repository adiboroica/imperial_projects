"""`/ws` WebSocket handler — `requestId`-correlated frames over a typed envelope."""

from __future__ import annotations

import logging
from typing import Optional

from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect
from pydantic import BaseModel, ValidationError

from src.config import get_app_url
from src.dependencies import (
    COOKIE_NAME,
    get_api_key_service,
    get_auth_service,
    get_generation_service,
)
from src.models.auth import User
from src.models.errors import (
    ApiKeyCorrupted,
    InvalidNodeConnection,
    InvalidNodeType,
    NlpParseError,
    OpenAIConfigurationError,
    OpenAIRateLimit,
    OpenAIRequestError,
    OpenAIUnavailable,
    SessionExpired,
    SessionNotFound,
    Unauthenticated,
    UserNotFound,
)
from src.models.graph import GamebookGraph
from src.models.ws import (
    CLIENT_PAYLOAD_TYPES,
    AddActionPayload,
    ConnectNodePayload,
    GenerateActionsPayload,
    GenerateManyPayload,
    GenerateNarrativePayload,
    InitialStoryPayload,
    ProgressUpdatePayload,
    RequestCompletePayload,
    WSEnvelope,
)
from src.services import ApiKeyService, AuthService, GenerationService

logger = logging.getLogger(__name__)

router = APIRouter()

# WebSocket close codes
CODE_VALIDATION_FAILED = 1003
CODE_AUTH_FAILED = 4001
CODE_ORIGIN_MISMATCH = 4003


# ---------- Public handler (thin orchestration) ----------


@router.websocket("/ws")
async def websocket_handler(
    ws: WebSocket,
    auth: AuthService = Depends(get_auth_service),
    api_keys: ApiKeyService = Depends(get_api_key_service),
    generation: GenerationService = Depends(get_generation_service),
) -> None:
    if not _check_origin(ws):
        await ws.close(code=CODE_ORIGIN_MISMATCH)
        return

    session_id = ws.cookies.get(COOKIE_NAME)
    user = await _authenticate(ws, auth, session_id)
    if user is None:
        return  # already closed by the helper

    await ws.accept()
    api_key = await _resolve_api_key(user, api_keys)

    try:
        while True:
            await _handle_one_message(ws, auth, generation, api_key, session_id)
    except WebSocketDisconnect:
        return
    except _CloseConnection:
        return


# ---------- Connection-level helpers ----------


def _check_origin(ws: WebSocket) -> bool:
    origin = ws.headers.get("origin", "")
    return not origin or origin == get_app_url()


async def _authenticate(
    ws: WebSocket, auth: AuthService, session_id: str | None
) -> Optional[User]:
    """Validate the session cookie. On failure, closes the socket and returns None."""
    try:
        return await auth.validate_session(session_id)
    except (Unauthenticated, SessionNotFound, SessionExpired, UserNotFound):
        await ws.close(code=CODE_AUTH_FAILED)
        return None


async def _revalidate_session(
    ws: WebSocket, auth: AuthService, session_id: str | None
) -> None:
    """Per-message session check — closes the socket and raises `_CloseConnection`
    if the session was invalidated server-side (e.g. by a logout) since the
    handshake. Called before dispatching every frame."""
    try:
        await auth.validate_session(session_id)
    except (Unauthenticated, SessionNotFound, SessionExpired, UserNotFound) as exc:
        await ws.close(code=CODE_AUTH_FAILED)
        raise _CloseConnection from exc


async def _resolve_api_key(user: User, api_keys: ApiKeyService) -> str | None:
    """Fetch the user's stored OpenAI key. Falls back to the server pool on cipher errors."""
    try:
        return await api_keys.get_for_user(user.email)
    except ApiKeyCorrupted:
        logger.warning(
            "ApiKeyCorrupted for %s; falling back to server pool", user.email
        )
        return None


# ---------- Per-message helpers ----------


class _CloseConnection(Exception):
    """Internal sentinel — bubbles up to close the WS without throwing through the handler."""


async def _handle_one_message(
    ws: WebSocket,
    auth: AuthService,
    generation: GenerationService,
    api_key: str | None,
    session_id: str | None,
) -> None:
    raw = await ws.receive_json()
    envelope, payload = await _validate_frame(ws, raw)
    await _revalidate_session(ws, auth, session_id)

    try:
        graph = await _dispatch(envelope, payload, generation, api_key, ws)
        await _send(
            ws,
            envelope.request_id,
            "requestComplete",
            RequestCompletePayload(graph=graph),
        )
    except Exception as exc:
        try:
            await _send_error_for(exc, ws, envelope.request_id)
        except (WebSocketDisconnect, RuntimeError) as send_exc:
            # Socket closed under us; swallow and let the outer loop terminate.
            logger.info(
                "WS error frame send failed (socket likely closed): %s", send_exc
            )
            raise _CloseConnection from send_exc


async def _validate_frame(
    ws: WebSocket, raw: object
) -> tuple[WSEnvelope, BaseModel]:
    """Return ``(envelope, payload)``; raises `_CloseConnection` after closing on validation failure."""
    try:
        envelope = WSEnvelope.model_validate(raw)
    except ValidationError as exc:
        logger.info("WS envelope validation failed: %s", exc)
        await ws.close(code=CODE_VALIDATION_FAILED)
        raise _CloseConnection from exc

    payload_cls = CLIENT_PAYLOAD_TYPES.get(envelope.type)
    if payload_cls is None:
        logger.info("Unknown WS message type: %s", envelope.type)
        await ws.close(code=CODE_VALIDATION_FAILED)
        raise _CloseConnection

    try:
        payload = payload_cls.model_validate(envelope.payload)
    except ValidationError as exc:
        logger.info("WS payload validation failed for %s: %s", envelope.type, exc)
        await ws.close(code=CODE_VALIDATION_FAILED)
        raise _CloseConnection from exc

    return envelope, payload


# ---------- Dispatch + send ----------


async def _dispatch(
    envelope: WSEnvelope,
    payload: BaseModel,
    generation: GenerationService,
    api_key: str | None,
    ws: WebSocket,
) -> GamebookGraph:
    if isinstance(payload, InitialStoryPayload):
        return await generation.generate_initial_story(
            payload.genre, payload.attributes, payload.temperature, api_key
        )
    if isinstance(payload, GenerateActionsPayload):
        return await generation.generate_actions_from_narrative(
            payload.graph,
            payload.node_id,
            payload.num_actions,
            payload.temperature,
            api_key,
        )
    if isinstance(payload, AddActionPayload):
        return await generation.add_actions(
            payload.graph,
            payload.node_id,
            payload.num_actions,
            payload.temperature,
            api_key,
        )
    if isinstance(payload, GenerateNarrativePayload):
        return await generation.generate_narrative_from_action(
            payload.graph,
            payload.node_id,
            payload.is_ending,
            payload.descriptor,
            payload.details,
            payload.style,
            payload.temperature,
            api_key,
        )
    if isinstance(payload, ConnectNodePayload):
        return await generation.bridge_node(
            payload.graph,
            payload.source_id,
            payload.target_id,
            payload.temperature,
            api_key,
        )
    if isinstance(payload, GenerateManyPayload):

        async def progress(
            graph: GamebookGraph, nodes_generated: int, percentage: float
        ) -> None:
            await _send(
                ws,
                envelope.request_id,
                "progressUpdate",
                ProgressUpdatePayload(
                    graph=graph,
                    nodes_generated=nodes_generated,
                    percentage=percentage,
                ),
            )

        return await generation.generate_many(
            payload.graph,
            payload.node_id,
            payload.depth,
            payload.num_actions,
            payload.temperature,
            progress,
            api_key,
        )
    raise ValueError(f"Unknown payload type: {type(payload).__name__}")


async def _send_error_for(
    exc: BaseException, ws: WebSocket, request_id: str
) -> None:
    """Map a raised domain error to the matching WS error frame."""
    if isinstance(exc, OpenAIRateLimit):
        await _send(
            ws,
            request_id,
            "rateLimitError",
            {"message": "OpenAI rate limit exceeded; please retry."},
        )
        return
    if isinstance(exc, OpenAIUnavailable):
        await _send(
            ws,
            request_id,
            "openaiError",
            {"message": "OpenAI service is temporarily unavailable."},
        )
        return
    if isinstance(exc, OpenAIRequestError):
        await _send(ws, request_id, "openaiError", {"message": str(exc)})
        return
    if isinstance(exc, OpenAIConfigurationError):
        await _send(
            ws,
            request_id,
            "openaiError",
            {"message": "No OpenAI API key configured."},
        )
        return
    if isinstance(exc, NlpParseError):
        await _send(
            ws,
            request_id,
            "nlpParseError",
            {"message": "The model returned a response we could not parse."},
        )
        return
    if isinstance(exc, (InvalidNodeType, InvalidNodeConnection)):
        await _send(ws, request_id, "error", {"message": str(exc)})
        return
    logger.exception("Unexpected WS handler error", exc_info=exc)
    await _send(ws, request_id, "error", {"message": "Unexpected server error"})


async def _send(
    ws: WebSocket, request_id: str, msg_type: str, payload: BaseModel | dict
) -> None:
    body = (
        payload.model_dump(by_alias=True, mode="json")
        if isinstance(payload, BaseModel)
        else payload
    )
    await ws.send_json(
        {"requestId": request_id, "type": msg_type, "payload": body}
    )
