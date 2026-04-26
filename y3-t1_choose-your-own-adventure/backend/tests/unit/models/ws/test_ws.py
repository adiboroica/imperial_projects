"""WSEnvelope and per-message WS payload tests."""

from __future__ import annotations

import uuid

import pytest
from pydantic import ValidationError

from src.models.graph import GamebookGraph, NarrativeNode
from src.models.ws import (
    CLIENT_PAYLOAD_TYPES,
    GenerateActionsPayload,
    InitialStoryPayload,
    WSEnvelope,
)


# --- Core Functionality ---


def test_envelope_validates_uuid_v4_request_id():
    rid = str(uuid.uuid4())
    env = WSEnvelope(request_id=rid, type="initialStory", payload={})
    assert env.request_id == rid


def test_initial_story_payload_accepts_minimal_input():
    payload = InitialStoryPayload(
        genre="fantasy", attributes={"hero": "elf"}, temperature=0.5
    )
    assert payload.genre == "fantasy"


def test_generate_actions_payload_validates_graph():
    g = GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")])
    payload = GenerateActionsPayload(
        graph=g, node_id=0, num_actions=2, temperature=0.5
    )
    assert payload.node_id == 0


def test_client_payload_types_covers_six_message_types():
    expected = {
        "initialStory",
        "generateActions",
        "addAction",
        "generateNarrative",
        "connectNode",
        "generateMany",
    }
    assert set(CLIENT_PAYLOAD_TYPES.keys()) == expected


# --- Edge Cases ---


def test_envelope_rejects_missing_request_id():
    with pytest.raises(ValidationError):
        WSEnvelope.model_validate({"type": "initialStory", "payload": {}})


def test_envelope_rejects_non_uuid_v4_request_id():
    with pytest.raises(ValidationError):
        WSEnvelope.model_validate({
            "requestId": "not-a-uuid",
            "type": "initialStory",
            "payload": {},
        })


def test_initial_story_payload_rejects_empty_genre():
    with pytest.raises(ValidationError):
        InitialStoryPayload(genre="", attributes={}, temperature=0.5)


def test_generate_actions_payload_rejects_zero_num_actions():
    g = GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")])
    with pytest.raises(ValidationError):
        GenerateActionsPayload(
            graph=g, node_id=0, num_actions=0, temperature=0.5
        )
