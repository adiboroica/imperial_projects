"""GenerationService — orchestrates the LLM and duplicate analyser to expand the story graph."""

from __future__ import annotations

import logging
import random
from typing import Any, Awaitable, Callable

from src.ai.analyser import is_duplicate
from src.ai.llm import LLMClient
from src.ai.text_generator import TextGenerator
from src.constants import MAX_GENERATE_MANY_NODES
from src.models.errors import (
    InvalidNodeConnection,
    InvalidNodeType,
    NodeNotFound,
)
from src.models.graph import GamebookGraph, NarrativeNode

logger = logging.getLogger(__name__)

# A progress callback is invoked between batches in `generate_many`.
# It receives (graph, nodes_generated, percentage_complete).
ProgressCallback = Callable[[GamebookGraph, int, float], Awaitable[None]]


class GenerationService:
    """Stateless with respect to storage. Operates on graphs passed in by the caller."""

    def __init__(self, ending_chance_per_node: float = 0.25) -> None:
        self._ending_chance = ending_chance_per_node

    # ---------- Single-step expansions ----------

    async def generate_initial_story(
        self,
        genre: str,
        attributes: dict[str, Any],
        temperature: float,
        api_key: str | None = None,
    ) -> GamebookGraph:
        text_gen = self._make_text_generator(api_key, temperature)
        narrative = await text_gen.new_story(genre, attributes)
        graph = GamebookGraph(nodes=[NarrativeNode(node_id=0, data=narrative)])
        await self._expand_actions(graph, 0, num_actions=2, text_gen=text_gen)
        return graph

    async def generate_actions_from_narrative(
        self,
        graph: GamebookGraph,
        node_id: int,
        num_actions: int,
        temperature: float,
        api_key: str | None = None,
    ) -> GamebookGraph:
        if not graph.is_narrative(node_id):
            raise InvalidNodeType(
                f"Cannot generate actions from non-narrative node {node_id}"
            )
        text_gen = self._make_text_generator(api_key, temperature)
        await self._expand_actions(graph, node_id, num_actions, text_gen)
        return graph

    async def add_actions(
        self,
        graph: GamebookGraph,
        node_id: int,
        num_actions: int,
        temperature: float,
        api_key: str | None = None,
    ) -> GamebookGraph:
        if not graph.is_narrative(node_id):
            raise InvalidNodeType(
                f"Cannot add actions to non-narrative node {node_id}"
            )
        text_gen = self._make_text_generator(api_key, temperature)

        existing = graph.get_children(node_id)
        if not existing:
            await self._expand_actions(graph, node_id, num_actions, text_gen)
            return graph

        previous_text = " ".join(graph.get_paragraph_list(node_id))
        existing_actions = [graph.get_data(cid) for cid in existing]
        new_actions = await text_gen.add_actions(
            previous_text, existing_actions, num_actions
        )
        for action_text in new_actions:
            graph.make_action_node(parent_id=node_id, data=action_text)
        return graph

    async def generate_narrative_from_action(
        self,
        graph: GamebookGraph,
        node_id: int,
        is_ending: bool,
        descriptor: str | None,
        details: str | None,
        style: str | None,
        temperature: float,
        api_key: str | None = None,
    ) -> GamebookGraph:
        if graph.is_narrative(node_id):
            raise InvalidNodeType(
                f"Cannot generate narrative from non-action node {node_id}"
            )
        text_gen = self._make_text_generator(api_key, temperature)
        await self._expand_narrative(
            graph, node_id, is_ending, descriptor, details, style, text_gen
        )
        return graph

    async def bridge_node(
        self,
        graph: GamebookGraph,
        source_id: int,
        target_id: int,
        temperature: float,
        api_key: str | None = None,
    ) -> GamebookGraph:
        if source_id == target_id:
            raise InvalidNodeConnection(
                f"Cannot bridge a node to itself (id={source_id})"
            )
        if source_id not in graph.node_lookup:
            raise NodeNotFound(f"Source node not found: {source_id}")
        if target_id not in graph.node_lookup:
            raise NodeNotFound(f"Target node not found: {target_id}")

        text_gen = self._make_text_generator(api_key, temperature)
        bridge_text = await text_gen.bridge_content(
            graph.get_data(source_id), graph.get_data(target_id)
        )
        bridge_id = graph.make_narrative_node(parent_id=source_id, data=bridge_text)
        graph.connect_nodes(bridge_id, target_id)
        return graph

    async def generate_many(
        self,
        graph: GamebookGraph,
        node_id: int,
        depth: int,
        num_actions: int,
        temperature: float,
        progress: ProgressCallback,
        api_key: str | None = None,
    ) -> GamebookGraph:
        text_gen = self._make_text_generator(api_key, temperature)

        # Coerce non-narrative starts: expand the action into a narrative first.
        if not graph.is_narrative(node_id):
            node_id = await self._expand_narrative(
                graph,
                node_id,
                is_ending=False,
                descriptor=None,
                details=None,
                style=None,
                text_gen=text_gen,
            )

        expected_total = 1 + self._expected_descendants(depth, num_actions)
        nodes_generated = 0
        current_ids = [node_id]

        async def update_progress() -> None:
            pct = min(100.0, 100.0 * nodes_generated / max(1, expected_total))
            await progress(graph, nodes_generated, pct)

        for _ in range(depth):
            if nodes_generated >= MAX_GENERATE_MANY_NODES:
                logger.info(
                    "generate_many hit MAX_GENERATE_MANY_NODES=%d budget; stopping",
                    MAX_GENERATE_MANY_NODES,
                )
                break

            next_ids: list[int] = []
            for current_id in current_ids:
                if nodes_generated >= MAX_GENERATE_MANY_NODES:
                    break
                last_text = graph.get_data(current_id)
                if graph.is_ending(current_id) or await text_gen.has_story_ended(last_text):
                    continue

                action_ids = await self._expand_actions(
                    graph, current_id, num_actions, text_gen
                )
                nodes_generated += len(action_ids)
                await update_progress()

                for action_id in action_ids:
                    if nodes_generated >= MAX_GENERATE_MANY_NODES:
                        break
                    actions_so_far = graph.get_actions_list(action_id)
                    has_dup = any(
                        is_duplicate(x, y)
                        for x in actions_so_far
                        for y in actions_so_far
                        if x != y
                    )
                    if has_dup:
                        await self._expand_narrative(
                            graph,
                            action_id,
                            is_ending=True,
                            descriptor=None,
                            details=None,
                            style=None,
                            text_gen=text_gen,
                        )
                        continue
                    is_ending = random.random() < self._ending_chance
                    new_id = await self._expand_narrative(
                        graph,
                        action_id,
                        is_ending=is_ending,
                        descriptor=None,
                        details=None,
                        style=None,
                        text_gen=text_gen,
                    )
                    nodes_generated += 1
                    next_ids.append(new_id)
                    await update_progress()
            current_ids = next_ids
        # Final progress frame so the client always sees 100% (or the
        # budget-truncation snapshot) before `requestComplete`.
        await update_progress()
        return graph

    # ---------- Internals ----------

    @staticmethod
    def _make_text_generator(api_key: str | None, temperature: float) -> TextGenerator:
        return TextGenerator(LLMClient(api_key=api_key, temperature=temperature))

    @staticmethod
    async def _expand_actions(
        graph: GamebookGraph,
        node_id: int,
        num_actions: int,
        text_gen: TextGenerator,
    ) -> list[int]:
        previous_text = " ".join(graph.get_paragraph_list(node_id))
        action_texts = await text_gen.generate_actions(previous_text, num_actions)
        new_ids: list[int] = []
        for text in action_texts:
            new_ids.append(graph.make_action_node(parent_id=node_id, data=text))
        return new_ids

    @staticmethod
    async def _expand_narrative(
        graph: GamebookGraph,
        action_id: int,
        is_ending: bool,
        descriptor: str | None,
        details: str | None,
        style: str | None,
        text_gen: TextGenerator,
    ) -> int:
        # The action's "data" is what the player chose; rewrite into "You choose ...".
        action_text = graph.get_data(action_id)
        edited_action = await text_gen.action_to_second_person(action_text) + " "

        previous_text = " ".join(graph.get_paragraph_list(action_id))
        prompt = previous_text + " " + edited_action
        narrative = edited_action + await text_gen.generate_narrative(
            prompt,
            is_ending=is_ending,
            descriptor=descriptor,
            details=details,
            style=style,
        )
        return graph.make_narrative_node(
            parent_id=action_id, data=narrative, is_ending=is_ending
        )

    def _expected_descendants(self, depth: int, num_actions: int) -> int:
        """Best-guess subtree size used to project a percentage for `progressUpdate` frames."""
        if depth == 0:
            return 0
        if_end = 1
        if_no_end = 1 + num_actions + self._expected_descendants(depth - 1, num_actions)
        return int(
            num_actions
            * (self._ending_chance * if_end + (1 - self._ending_chance) * if_no_end)
        )
