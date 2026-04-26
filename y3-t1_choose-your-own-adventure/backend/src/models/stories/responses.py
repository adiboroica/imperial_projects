"""HTTP response shapes for the `/stories/*` routes."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field

from src.models.graph import GamebookGraph


class StoryListItem(BaseModel):
    """Lean view returned by `GET /stories`."""

    id: str
    name: str
    first_paragraph: str = Field(alias="firstParagraph")
    total_sections: int = Field(alias="totalSections")

    model_config = {"populate_by_name": True}


class StoryResponse(BaseModel):
    """Full view returned by `GET /stories/{id}`."""

    id: str
    name: str
    graph: GamebookGraph
    created_at: datetime = Field(alias="createdAt")
    updated_at: datetime = Field(alias="updatedAt")

    model_config = {"populate_by_name": True}


class CreatedStoryResponse(BaseModel):
    """`POST /stories` and `PATCH /stories/{id}` response — id + current name."""

    id: str
    name: str


class SaveGraphResponse(BaseModel):
    """`PUT /stories/{id}/graph` response — empty by design (the client already has the graph)."""
