"""`/stories/*` HTTP surface — story CRUD plus DOCX/TXT export."""

from __future__ import annotations

import logging

from fastapi import APIRouter, Depends, HTTPException, Response

from src.dependencies import (
    get_current_user,
    get_export_service,
    get_story_service,
)
from src.models.auth import User
from src.models.errors import StoryNotFound, UnsupportedExportFormat
from src.models.stories import (
    CreatedStoryResponse,
    CreateStoryRequest,
    SaveGraphRequest,
    SaveGraphResponse,
    StoryListItem,
    StoryResponse,
    UpdateStoryNameRequest,
)
from src.services import ExportFormat, ExportService, StoryService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/stories")


@router.post("", response_model=CreatedStoryResponse, status_code=201)
async def create_story(
    body: CreateStoryRequest,
    user: User = Depends(get_current_user),
    stories_service: StoryService = Depends(get_story_service),
) -> CreatedStoryResponse:
    story = await stories_service.create(user.email, name=body.name)
    return CreatedStoryResponse(id=story.id, name=story.name)


@router.get("", response_model=list[StoryListItem])
async def list_stories(
    user: User = Depends(get_current_user),
    stories_service: StoryService = Depends(get_story_service),
) -> list[StoryListItem]:
    return await stories_service.list_for_user(user.email)


@router.get("/{story_id}", response_model=StoryResponse)
async def get_story(
    story_id: str,
    user: User = Depends(get_current_user),
    stories_service: StoryService = Depends(get_story_service),
) -> StoryResponse:
    try:
        return await stories_service.get_by_id(story_id, user.email)
    except StoryNotFound as exc:
        raise HTTPException(status_code=404, detail="Story not found") from exc


@router.patch("/{story_id}", response_model=CreatedStoryResponse)
async def rename_story(
    story_id: str,
    body: UpdateStoryNameRequest,
    user: User = Depends(get_current_user),
    stories_service: StoryService = Depends(get_story_service),
) -> CreatedStoryResponse:
    try:
        story = await stories_service.rename(story_id, user.email, body.name)
    except StoryNotFound as exc:
        raise HTTPException(status_code=404, detail="Story not found") from exc
    return CreatedStoryResponse(id=story.id, name=story.name)


@router.put("/{story_id}/graph", response_model=SaveGraphResponse)
async def save_graph(
    story_id: str,
    body: SaveGraphRequest,
    user: User = Depends(get_current_user),
    stories_service: StoryService = Depends(get_story_service),
) -> SaveGraphResponse:
    # Strict graph invariants for persisted shapes — defends the DB against
    # cycle-free / connected-but-rootless / orphan-island payloads that pass
    # the always-on construction validator.
    try:
        body.graph.validate_persisted()
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    try:
        await stories_service.save_graph(story_id, user.email, body.graph)
    except StoryNotFound as exc:
        raise HTTPException(status_code=404, detail="Story not found") from exc
    return SaveGraphResponse()


@router.delete("/{story_id}", status_code=204)
async def delete_story(
    story_id: str,
    user: User = Depends(get_current_user),
    stories_service: StoryService = Depends(get_story_service),
) -> Response:
    try:
        await stories_service.delete(story_id, user.email)
    except StoryNotFound as exc:
        raise HTTPException(status_code=404, detail="Story not found") from exc
    return Response(status_code=204)


@router.get("/{story_id}/export")
async def export_story(
    story_id: str,
    format: str = "docx",
    user: User = Depends(get_current_user),
    export: ExportService = Depends(get_export_service),
) -> Response:
    try:
        export_format = ExportFormat(format.lower())
    except ValueError as exc:
        raise HTTPException(
            status_code=422,
            detail=f"Unsupported export format: {format}",
        ) from exc

    try:
        payload, mime_type, filename = await export.render(
            story_id, user.email, export_format
        )
    except StoryNotFound as exc:
        raise HTTPException(status_code=404, detail="Story not found") from exc
    except UnsupportedExportFormat as exc:
        raise HTTPException(status_code=422) from exc

    return Response(
        content=payload,
        media_type=mime_type,
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
