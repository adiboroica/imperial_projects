"""GamebookGraph and the node models — Pydantic shape + structural operations."""

from __future__ import annotations

import pytest
from pydantic import ValidationError

from src.models.errors import CycleError, NodeNotFound
from src.models.graph import ActionNode, GamebookGraph, NarrativeNode


# ---------- Node model shapes ----------


def test_narrative_node_round_trip():
    node = NarrativeNode(node_id=0, data="Once upon a time")
    dumped = node.model_dump(by_alias=True)
    assert dumped["nodeId"] == 0
    assert dumped["type"] == "narrative"
    assert dumped["isEnding"] is False
    restored = NarrativeNode.model_validate(dumped)
    assert restored == node


def test_action_node_round_trip():
    node = ActionNode(node_id=1, data="Open the door")
    dumped = node.model_dump(by_alias=True)
    assert dumped["nodeId"] == 1
    assert dumped["type"] == "action"
    restored = ActionNode.model_validate(dumped)
    assert restored == node


# ---------- Empty graph ----------


def test_empty_graph_serialises_to_empty_nodes():
    graph = GamebookGraph()
    assert graph.to_graph_dict() == {"nodes": []}
    assert graph.next_node_id == 0


# ---------- Mutation ----------


def test_make_narrative_then_action_preserves_invariants():
    graph = GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")])
    action_id = graph.make_action_node(parent_id=0, data="walk away")
    assert action_id == 1
    assert graph.is_action(action_id)
    assert action_id in graph.node_lookup[0].children_ids
    assert graph.parent_lookup[action_id] == [0]
    assert graph.next_node_id == 2


def test_make_narrative_node_on_unknown_parent_raises():
    graph = GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")])
    with pytest.raises(NodeNotFound):
        graph.make_narrative_node(parent_id=99, data="unreachable")


# ---------- connect_nodes / cycles ----------


def test_connect_nodes_adds_edge_when_no_cycle():
    nodes = [
        NarrativeNode(node_id=0, data="root"),
        ActionNode(node_id=1, data="action"),
    ]
    graph = GamebookGraph(nodes=nodes)
    graph.connect_nodes(0, 1)
    assert 1 in graph.node_lookup[0].children_ids


def test_connect_nodes_raises_on_cycle():
    nodes = [
        NarrativeNode(node_id=0, data="a", children_ids=[1]),
        ActionNode(node_id=1, data="b", children_ids=[2]),
        NarrativeNode(node_id=2, data="c"),
    ]
    graph = GamebookGraph(nodes=nodes)
    with pytest.raises(CycleError):
        graph.connect_nodes(2, 0)
    # Graph unchanged.
    assert graph.node_lookup[2].children_ids == []


# ---------- Validation on construction ----------


def test_duplicate_node_ids_rejected():
    with pytest.raises(ValidationError):
        GamebookGraph(
            nodes=[
                NarrativeNode(node_id=0, data="a"),
                NarrativeNode(node_id=0, data="b"),
            ]
        )


def test_orphan_child_reference_rejected():
    with pytest.raises(ValidationError):
        GamebookGraph(
            nodes=[NarrativeNode(node_id=0, data="root", children_ids=[42])]
        )


# ---------- Traversal ----------


def test_paragraph_list_walks_to_root():
    nodes = [
        NarrativeNode(node_id=0, data="alpha", children_ids=[1]),
        ActionNode(node_id=1, data="choose", children_ids=[2]),
        NarrativeNode(node_id=2, data="beta"),
    ]
    graph = GamebookGraph(nodes=nodes)
    assert graph.get_paragraph_list(2) == ["alpha", "beta"]


def test_paragraph_list_on_disconnected_node_returns_only_itself():
    nodes = [
        NarrativeNode(node_id=0, data="root"),
        NarrativeNode(node_id=1, data="island"),
    ]
    graph = GamebookGraph(nodes=nodes)
    assert graph.get_paragraph_list(1) == ["island"]


# ---------- Round-trip ----------


def test_from_graph_dict_round_trip():
    nodes = [
        NarrativeNode(node_id=0, data="alpha", children_ids=[1]),
        ActionNode(node_id=1, data="choose", children_ids=[2]),
        NarrativeNode(node_id=2, data="omega", is_ending=True),
    ]
    original = GamebookGraph(nodes=nodes)
    restored = GamebookGraph.from_graph_dict(original.to_graph_dict())
    assert restored.to_graph_dict() == original.to_graph_dict()
    assert restored.is_ending(2) is True


# ---------- Type guards ----------


def test_type_guards_dispatch_on_type():
    nodes = [
        NarrativeNode(node_id=0, data="n", is_ending=True),
        ActionNode(node_id=1, data="a"),
    ]
    graph = GamebookGraph(nodes=nodes)
    assert graph.is_narrative(0) is True
    assert graph.is_action(0) is False
    assert graph.is_ending(0) is True
    assert graph.is_action(1) is True
    assert graph.is_narrative(1) is False
    assert graph.is_ending(1) is False
