"""GenerationService unit tests.

Tests inject mocked `LLMClient` / `TextGenerator` rather than real OpenAI calls.
We stub the public `TextGenerator` API by patching the module-level factory in
`generation_service.py`.
"""

from __future__ import annotations

from unittest.mock import AsyncMock, patch

import pytest

from src.models.errors import (
    InvalidNodeConnection,
    InvalidNodeType,
    NodeNotFound,
)
from src.models.graph import ActionNode, GamebookGraph, NarrativeNode
from src.services.generation import GenerationService


@pytest.fixture
def text_gen_mock():
    """A scriptable AsyncMock standing in for `TextGenerator`."""
    m = AsyncMock()
    m.action_to_second_person.return_value = "You choose to act"
    m.generate_actions.return_value = ["Run away", "Fight back"]
    m.add_actions.return_value = ["Hide"]
    m.generate_narrative.return_value = "And so the story continued."
    m.bridge_content.return_value = "Bridging passage."
    m.has_story_ended.return_value = False
    m.new_story.return_value = "Once upon a time…"
    return m


@pytest.fixture
def service(text_gen_mock):
    """Patches `_make_text_generator` so all calls use our mock."""
    s = GenerationService()
    with patch.object(s, "_make_text_generator", return_value=text_gen_mock):
        yield s


# --- Core Functionality ---


@pytest.mark.asyncio
async def test_generate_initial_story_creates_root_with_actions(service):
    g = await service.generate_initial_story("fantasy", {"hero": "elf"}, 0.5)
    assert g.is_narrative(0)
    assert len(g.nodes) >= 3  # root + 2 actions


@pytest.mark.asyncio
async def test_generate_actions_from_narrative_appends_actions(service):
    g = GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")])
    await service.generate_actions_from_narrative(g, 0, 2, 0.5)
    children = g.get_children(0)
    assert len(children) == 2
    for cid in children:
        assert g.is_action(cid)


@pytest.mark.asyncio
async def test_add_actions_extends_existing_set(service, text_gen_mock):
    g = GamebookGraph(
        nodes=[
            NarrativeNode(node_id=0, data="root", children_ids=[1]),
            ActionNode(node_id=1, data="run"),
        ]
    )
    await service.add_actions(g, 0, 1, 0.5)
    assert len(g.get_children(0)) == 2


@pytest.mark.asyncio
async def test_generate_narrative_from_action_appends_narrative(service):
    g = GamebookGraph(
        nodes=[
            NarrativeNode(node_id=0, data="root", children_ids=[1]),
            ActionNode(node_id=1, data="run"),
        ]
    )
    await service.generate_narrative_from_action(g, 1, False, None, None, None, 0.5)
    assert len(g.get_children(1)) == 1
    new_id = g.get_children(1)[0]
    assert g.is_narrative(new_id)


@pytest.mark.asyncio
async def test_bridge_node_creates_narrative_link(service):
    g = GamebookGraph(
        nodes=[
            NarrativeNode(node_id=0, data="A"),
            NarrativeNode(node_id=1, data="B"),
        ]
    )
    await service.bridge_node(g, 0, 1, 0.5)
    # Node 0 should now have a narrative child connecting to 1.
    assert len(g.get_children(0)) >= 1


# --- Edge Cases ---


@pytest.mark.asyncio
async def test_generate_actions_on_action_node_raises_invalid_node_type(service):
    g = GamebookGraph(
        nodes=[
            NarrativeNode(node_id=0, data="root", children_ids=[1]),
            ActionNode(node_id=1, data="run"),
        ]
    )
    with pytest.raises(InvalidNodeType):
        await service.generate_actions_from_narrative(g, 1, 2, 0.5)


@pytest.mark.asyncio
async def test_generate_narrative_on_narrative_node_raises_invalid_node_type(service):
    g = GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")])
    with pytest.raises(InvalidNodeType):
        await service.generate_narrative_from_action(
            g, 0, False, None, None, None, 0.5
        )


@pytest.mark.asyncio
async def test_bridge_node_same_id_raises_invalid_node_connection(service):
    g = GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")])
    with pytest.raises(InvalidNodeConnection):
        await service.bridge_node(g, 0, 0, 0.5)


@pytest.mark.asyncio
async def test_bridge_node_unknown_source_raises_node_not_found(service):
    g = GamebookGraph(
        nodes=[
            NarrativeNode(node_id=0, data="root"),
            NarrativeNode(node_id=1, data="other"),
        ]
    )
    with pytest.raises(NodeNotFound):
        await service.bridge_node(g, 99, 1, 0.5)


@pytest.mark.asyncio
async def test_generate_many_with_depth_zero_returns_unchanged(service, text_gen_mock):
    g = GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")])
    progress = AsyncMock()
    result = await service.generate_many(g, 0, 0, 2, 0.5, progress)
    assert result is g
    text_gen_mock.has_story_ended.assert_not_awaited()
