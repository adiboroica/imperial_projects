"""Story model unit tests."""

from __future__ import annotations

import pytest
from pydantic import ValidationError

from src.models.graph import GamebookGraph, NarrativeNode
from src.models.stories import (
    CreateStoryRequest,
    SaveGraphRequest,
    StoryListItem,
    StoryResponse,
    UpdateStoryNameRequest,
)


# --- Core Functionality ---


def test_create_story_request_all_fields_optional():
    body = CreateStoryRequest()
    assert body.name is None
    assert body.genre is None
    assert body.attributes is None


def test_update_story_name_request_accepts_valid_name():
    body = UpdateStoryNameRequest(name="My new story")
    assert body.name == "My new story"


def test_save_graph_request_validates_graph():
    g = GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")])
    body = SaveGraphRequest(graph=g)
    assert len(body.graph.nodes) == 1


def test_story_list_item_aliases():
    item = StoryListItem(
        id="s1", name="My", first_paragraph="hi", total_sections=2
    )
    dumped = item.model_dump(by_alias=True)
    assert dumped["firstParagraph"] == "hi"
    assert dumped["totalSections"] == 2


def test_story_response_round_trip():
    g = GamebookGraph()
    response = StoryResponse(
        id="s1",
        name="Story",
        graph=g,
        created_at="2026-01-01T00:00:00+00:00",
        updated_at="2026-01-02T00:00:00+00:00",
    )
    dumped = response.model_dump(by_alias=True, mode="json")
    assert "createdAt" in dumped
    assert "updatedAt" in dumped


# --- Edge Cases ---


def test_update_story_name_rejects_empty():
    with pytest.raises(ValidationError):
        UpdateStoryNameRequest(name="")


def test_update_story_name_rejects_too_long():
    with pytest.raises(ValidationError):
        UpdateStoryNameRequest(name="x" * 250)


def test_save_graph_request_rejects_invalid_graph():
    # Two nodes with the same id is a structural error.
    with pytest.raises(ValidationError):
        SaveGraphRequest(
            graph=GamebookGraph.model_validate({
                "nodes": [
                    {"nodeId": 0, "data": "a", "type": "narrative"},
                    {"nodeId": 0, "data": "b", "type": "narrative"},
                ]
            })
        )
