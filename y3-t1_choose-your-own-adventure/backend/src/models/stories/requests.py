"""HTTP request shapes for the `/stories/*` routes."""

from __future__ import annotations

from typing import Any

from pydantic import BaseModel, Field

from src.models.graph import GamebookGraph


class CreateStoryRequest(BaseModel):
    """`POST /stories` body — every field optional; defaults applied at creation."""

    name: str | None = None
    genre: str | None = None
    attributes: dict[str, Any] | None = None


class UpdateStoryNameRequest(BaseModel):
    """`PATCH /stories/{id}` body."""

    name: str = Field(min_length=1, max_length=200)


class SaveGraphRequest(BaseModel):
    """`PUT /stories/{id}/graph` body. Structural validation is delegated to `GamebookGraph`."""

    graph: GamebookGraph
