"""Client → server WS payload models, plus the type → class lookup table."""

from __future__ import annotations

from typing import Any

from pydantic import BaseModel, Field

from src.models.graph import GamebookGraph


class InitialStoryPayload(BaseModel):
    """`type=initialStory` — generate the root narrative and its first actions."""

    genre: str = Field(min_length=1)
    attributes: dict[str, Any] = Field(default_factory=dict)
    temperature: float = Field(default=0.5, ge=0.0, le=1.0)


class GenerateActionsPayload(BaseModel):
    """`type=generateActions` — expand a narrative node with N action children."""

    graph: GamebookGraph
    node_id: int = Field(alias="nodeId")
    num_actions: int = Field(alias="numActions", ge=1, le=4)
    temperature: float = Field(default=0.5, ge=0.0, le=1.0)

    model_config = {"populate_by_name": True}


class AddActionPayload(BaseModel):
    """`type=addAction` — add more action children to a narrative that already has some."""

    graph: GamebookGraph
    node_id: int = Field(alias="nodeId")
    num_actions: int = Field(alias="numActions", ge=1, le=4)
    temperature: float = Field(default=0.5, ge=0.0, le=1.0)

    model_config = {"populate_by_name": True}


class GenerateNarrativePayload(BaseModel):
    """`type=generateNarrative` — expand an action node with a narrative continuation."""

    graph: GamebookGraph
    node_id: int = Field(alias="nodeId")
    is_ending: bool = Field(default=False, alias="isEnding")
    descriptor: str | None = None
    details: str | None = None
    style: str | None = None
    temperature: float = Field(default=0.5, ge=0.0, le=1.0)

    model_config = {"populate_by_name": True}


class ConnectNodePayload(BaseModel):
    """`type=connectNode` — generate bridging narrative between two existing nodes."""

    graph: GamebookGraph
    source_id: int = Field(alias="sourceId")
    target_id: int = Field(alias="targetId")
    temperature: float = Field(default=0.5, ge=0.0, le=1.0)

    model_config = {"populate_by_name": True}


class GenerateManyPayload(BaseModel):
    """`type=generateMany` — bulk-expand a subtree to a given depth.

    Hard caps `depth` and `num_actions` at 4 each to keep worst-case branching
    bounded; the service-layer `MAX_GENERATE_MANY_NODES` budget is the second
    line of defence.
    """

    graph: GamebookGraph
    node_id: int = Field(alias="nodeId")
    depth: int = Field(ge=1, le=4)
    num_actions: int = Field(alias="numActions", ge=1, le=4)
    temperature: float = Field(default=0.5, ge=0.0, le=1.0)

    model_config = {"populate_by_name": True}


# Discriminator lookup — the router validates `WSEnvelope.payload` against the
# right model after dispatching on `WSEnvelope.type`. An unknown key here means
# an unknown WS message type, which the router treats as a 1003 close.
CLIENT_PAYLOAD_TYPES: dict[str, type[BaseModel]] = {
    "initialStory": InitialStoryPayload,
    "generateActions": GenerateActionsPayload,
    "addAction": AddActionPayload,
    "generateNarrative": GenerateNarrativePayload,
    "connectNode": ConnectNodePayload,
    "generateMany": GenerateManyPayload,
}
