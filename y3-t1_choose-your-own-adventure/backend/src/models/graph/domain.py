"""GamebookGraph and the two node shapes — the only stateful model in `models/`."""

from __future__ import annotations

from collections import defaultdict
from typing import Annotated, Literal, Union

from pydantic import BaseModel, Field, model_validator

from src.models.errors import CycleError, NodeNotFound

# Hard caps applied during validation — keep persisted graphs bounded so a
# malicious `PUT /stories/{id}/graph` payload cannot consume unbounded memory
# downstream.
MAX_NODES = 1024
MAX_NODE_DATA_LENGTH = 4096


class NarrativeNode(BaseModel):
    """Narrative paragraph; may also be flagged as an ending."""

    node_id: int = Field(alias="nodeId")
    data: str
    children_ids: list[int] = Field(default_factory=list, alias="childrenIds")
    is_ending: bool = Field(default=False, alias="isEnding")
    type: Literal["narrative"] = "narrative"

    model_config = {"populate_by_name": True}


class ActionNode(BaseModel):
    """Action choice between two narratives."""

    node_id: int = Field(alias="nodeId")
    data: str
    children_ids: list[int] = Field(default_factory=list, alias="childrenIds")
    type: Literal["action"] = "action"

    model_config = {"populate_by_name": True}


AnyNode = Annotated[Union[NarrativeNode, ActionNode], Field(discriminator="type")]


class GamebookGraph(BaseModel):
    """A directed acyclic graph of narrative and action nodes."""

    nodes: list[AnyNode] = Field(default_factory=list)

    model_config = {"populate_by_name": True}

    # ---------- Validation ----------

    @model_validator(mode="after")
    def _validate_structure(self) -> "GamebookGraph":
        # Empty graphs are allowed (used as the initial state); everything
        # else has to satisfy every invariant below. Note: services build
        # graphs incrementally, so we only enforce invariants that hold at
        # *every* mutation step — no root-presence or full-reachability
        # checks here. `validate_persisted` adds those for graphs that arrive
        # from outside the process (request bodies, DB loads).
        if not self.nodes:
            return self

        if len(self.nodes) > MAX_NODES:
            raise ValueError(
                f"Graph exceeds max size: {len(self.nodes)} > {MAX_NODES}"
            )

        # 1. Unique node ids + bounded data length.
        seen_ids: set[int] = set()
        for node in self.nodes:
            if node.node_id in seen_ids:
                raise ValueError(f"Duplicate node id: {node.node_id}")
            seen_ids.add(node.node_id)
            if len(node.data) > MAX_NODE_DATA_LENGTH:
                raise ValueError(
                    f"Node {node.node_id} data exceeds max length "
                    f"({len(node.data)} > {MAX_NODE_DATA_LENGTH})"
                )

        # 2. Children references resolve.
        for node in self.nodes:
            for child_id in node.children_ids:
                if child_id not in seen_ids:
                    raise ValueError(
                        f"Node {node.node_id} references missing child {child_id}"
                    )

        # 3. Action nodes always resolve into a narrative — an action with
        #    an action child would be malformed (the player picks an action,
        #    they don't pick "another action"). Narrative→narrative edges
        #    are allowed (used by `bridge_node`).
        lookup = {node.node_id: node for node in self.nodes}
        for node in self.nodes:
            if node.type != "action":
                continue
            for child_id in node.children_ids:
                if lookup[child_id].type != "narrative":
                    raise ValueError(
                        f"Action node {node.node_id} has non-narrative child "
                        f"{child_id}"
                    )

        # 4. Cycle-free — three-colour DFS catches back-edges and self-loops.
        WHITE, GREY, BLACK = 0, 1, 2
        colour: dict[int, int] = dict.fromkeys(seen_ids, WHITE)

        def visit(start: int) -> None:
            stack: list[tuple[int, int]] = [(start, 0)]
            while stack:
                node_id, idx = stack[-1]
                if idx == 0:
                    if colour[node_id] == GREY:
                        raise ValueError(
                            f"Graph contains a cycle through node {node_id}"
                        )
                    if colour[node_id] == BLACK:
                        stack.pop()
                        continue
                    colour[node_id] = GREY
                children = lookup[node_id].children_ids
                if idx < len(children):
                    stack[-1] = (node_id, idx + 1)
                    stack.append((children[idx], 0))
                else:
                    colour[node_id] = BLACK
                    stack.pop()

        for nid in seen_ids:
            if colour[nid] == WHITE:
                visit(nid)

        return self

    def validate_persisted(self) -> "GamebookGraph":
        """Strict invariants for graphs arriving from outside the process —
        request bodies, DB loads. Adds root-contract + full-reachability on
        top of the always-on `_validate_structure` checks. Service-layer
        callers building graphs incrementally MUST NOT call this until the
        build is complete."""
        if not self.nodes:
            return self

        lookup = {node.node_id: node for node in self.nodes}
        if 0 not in lookup:
            raise ValueError("Persisted graph has no root node (node_id=0)")
        if lookup[0].type != "narrative":
            raise ValueError("Root node (node_id=0) must be narrative")

        seen_ids = set(lookup.keys())
        reachable: set[int] = set()
        frontier: list[int] = [0]
        while frontier:
            cur = frontier.pop()
            if cur in reachable:
                continue
            reachable.add(cur)
            frontier.extend(lookup[cur].children_ids)
        if reachable != seen_ids:
            orphans = sorted(seen_ids - reachable)
            raise ValueError(
                f"Persisted graph has unreachable node(s) from root: {orphans}"
            )
        return self

    def revalidate(self) -> "GamebookGraph":
        """Re-run structural validation after a batch of external mutations.

        Pydantic v2 `model_validator(mode="after")` only fires on construction.
        Callers that mutate `nodes` directly (rather than through the methods
        below, which preserve invariants) should call this to confirm the
        graph is still well-formed.
        """
        return self._validate_structure()

    # ---------- Serialisation ----------

    @classmethod
    def from_graph_dict(cls, graph: dict) -> "GamebookGraph":
        return cls.model_validate(graph)

    def to_graph_dict(self) -> dict:
        return self.model_dump(by_alias=True, mode="json")

    # ---------- Derived views ----------

    @property
    def node_lookup(self) -> dict[int, NarrativeNode | ActionNode]:
        return {node.node_id: node for node in self.nodes}

    @property
    def parent_lookup(self) -> dict[int, list[int]]:
        result: dict[int, list[int]] = defaultdict(list)
        for node in self.nodes:
            for child_id in node.children_ids:
                result[child_id].append(node.node_id)
        return result

    @property
    def next_node_id(self) -> int:
        return max((node.node_id for node in self.nodes), default=-1) + 1

    # ---------- Read helpers ----------

    def get_node(self, node_id: int) -> NarrativeNode | ActionNode:
        if node_id not in self.node_lookup:
            raise NodeNotFound(f"Node not found: {node_id}")
        return self.node_lookup[node_id]

    def is_narrative(self, node_id: int) -> bool:
        return self.get_node(node_id).type == "narrative"

    def is_action(self, node_id: int) -> bool:
        return self.get_node(node_id).type == "action"

    def is_ending(self, node_id: int) -> bool:
        node = self.get_node(node_id)
        return isinstance(node, NarrativeNode) and node.is_ending

    def get_data(self, node_id: int) -> str:
        return self.get_node(node_id).data

    def get_children(self, node_id: int) -> list[int]:
        return list(self.get_node(node_id).children_ids)

    def get_paragraph_list(self, end_node_id: int) -> list[str]:
        """Walk parents from `end_node_id` to the root, collecting narrative paragraphs."""
        rev: list[str] = []
        visited: set[int] = set()
        cur: int | None = end_node_id
        while cur is not None and cur not in visited:
            visited.add(cur)
            if cur not in self.node_lookup:
                break
            node = self.node_lookup[cur]
            if isinstance(node, NarrativeNode) and node.data:
                rev.append(node.data)
            parents = self.parent_lookup.get(cur, [])
            cur = parents[0] if parents else None
        return list(reversed(rev))

    def get_actions_list(self, end_node_id: int) -> list[str]:
        """Walk parents from `end_node_id` to the root, collecting action texts."""
        actions: list[str] = []
        visited: set[int] = set()
        cur: int | None = end_node_id
        while cur is not None and cur not in visited:
            visited.add(cur)
            if cur not in self.node_lookup:
                break
            node = self.node_lookup[cur]
            if isinstance(node, ActionNode) and node.data:
                actions.append(node.data)
            parents = self.parent_lookup.get(cur, [])
            cur = parents[0] if parents else None
        return actions

    # ---------- Mutation ----------

    def make_narrative_node(
        self, parent_id: int, data: str, is_ending: bool = False
    ) -> int:
        if parent_id not in self.node_lookup:
            raise NodeNotFound(f"Parent node not found: {parent_id}")
        new_id = self.next_node_id
        self.nodes.append(NarrativeNode(node_id=new_id, data=data, is_ending=is_ending))
        self._append_child(parent_id, new_id)
        return new_id

    def make_action_node(self, parent_id: int, data: str) -> int:
        if parent_id not in self.node_lookup:
            raise NodeNotFound(f"Parent node not found: {parent_id}")
        new_id = self.next_node_id
        self.nodes.append(ActionNode(node_id=new_id, data=data))
        self._append_child(parent_id, new_id)
        return new_id

    def connect_nodes(self, parent_id: int, child_id: int) -> None:
        if parent_id not in self.node_lookup:
            raise NodeNotFound(f"Parent node not found: {parent_id}")
        if child_id not in self.node_lookup:
            raise NodeNotFound(f"Child node not found: {child_id}")
        if self._is_reachable(child_id, parent_id):
            raise CycleError(
                f"Connecting {parent_id} -> {child_id} would create a cycle"
            )
        self._append_child(parent_id, child_id)

    def set_data(self, node_id: int, data: str) -> None:
        node = self.get_node(node_id)
        node.data = data

    def set_ending_narrative(self, node_id: int, is_ending: bool) -> None:
        node = self.get_node(node_id)
        if isinstance(node, NarrativeNode):
            node.is_ending = is_ending

    # ---------- Internals ----------

    def _append_child(self, parent_id: int, child_id: int) -> None:
        for node in self.nodes:
            if node.node_id == parent_id and child_id not in node.children_ids:
                node.children_ids.append(child_id)
                return

    def _is_reachable(self, source: int, target: int) -> bool:
        if source == target:
            return True
        visited: set[int] = set()
        stack: list[int] = [source]
        while stack:
            cur = stack.pop()
            if cur == target:
                return True
            if cur in visited or cur not in self.node_lookup:
                continue
            visited.add(cur)
            stack.extend(self.node_lookup[cur].children_ids)
        return False
