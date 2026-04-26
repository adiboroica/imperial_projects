"""`/api-key` HTTP surface — read and write the user's OpenAI API key."""

from __future__ import annotations

import logging

from fastapi import APIRouter, Depends, HTTPException

from src.dependencies import get_api_key_service, get_current_user
from src.models.api_key import ApiKeyRequest, ApiKeyResponse
from src.models.auth import User
from src.models.errors import UserNotFound
from src.services import ApiKeyService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api-key")


@router.get("", response_model=ApiKeyResponse)
async def get_api_key(
    user: User = Depends(get_current_user),
    api_keys: ApiKeyService = Depends(get_api_key_service),
) -> ApiKeyResponse:
    try:
        decrypted = await api_keys.get_for_user(user.email)
    except UserNotFound as exc:
        # Race: account was deleted between session check and lookup.
        raise HTTPException(status_code=404, detail="User not found") from exc
    return ApiKeyResponse(api_key=decrypted)


@router.put("", response_model=ApiKeyResponse)
async def update_api_key(
    body: ApiKeyRequest,
    user: User = Depends(get_current_user),
    api_keys: ApiKeyService = Depends(get_api_key_service),
) -> ApiKeyResponse:
    try:
        await api_keys.update_for_user(user.email, body.api_key)
    except UserNotFound as exc:
        raise HTTPException(status_code=404, detail="User not found") from exc
    return ApiKeyResponse(api_key=body.api_key)
