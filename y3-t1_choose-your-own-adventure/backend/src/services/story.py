"""StoryService — story CRUD."""

from __future__ import annotations

import logging
from datetime import datetime, timezone
from uuid import uuid4

from src.models.errors import StoryNotFound
from src.models.graph import GamebookGraph, NarrativeNode
from src.models.stories import Story, StoryListItem, StoryResponse
from src.repositories import StoryRepository

logger = logging.getLogger(__name__)

_NO_PARAGRAPH_PLACEHOLDER = "ATTENTION: First paragraph of story not yet generated."


class StoryService:
    """Owns the story lifecycle. Single repository dependency."""

    def __init__(self, story_repository: StoryRepository) -> None:
        self._stories = story_repository

    async def create(
        self,
        user_email: str,
        name: str | None = None,
    ) -> Story:
        now = datetime.now(timezone.utc)
        story = Story(
            id=str(uuid4()),
            user_email=user_email,
            name=name or "Story",
            graph=GamebookGraph(),
            created_at=now,
            updated_at=now,
        )
        await self._stories.create(story)
        logger.info("Created story %s for %s", story.id, user_email)
        return story

    async def list_for_user(self, user_email: str) -> list[StoryListItem]:
        stories = await self._stories.list_for_user(user_email)
        return [self._to_list_item(s) for s in stories]

    async def get_by_id(self, story_id: str, user_email: str) -> StoryResponse:
        story = await self._stories.get_by_id_for_user(story_id, user_email)
        if story is None:
            raise StoryNotFound(story_id)
        return StoryResponse(
            id=story.id,
            name=story.name,
            graph=story.graph,
            created_at=story.created_at,
            updated_at=story.updated_at,
        )

    async def get_full(self, story_id: str, user_email: str) -> Story:
        """Return the raw `Story` (used by ExportService). Raises `StoryNotFound`."""
        story = await self._stories.get_by_id_for_user(story_id, user_email)
        if story is None:
            raise StoryNotFound(story_id)
        return story

    async def rename(self, story_id: str, user_email: str, name: str) -> Story:
        return await self._stories.update_name(story_id, user_email, name)

    async def save_graph(
        self, story_id: str, user_email: str, graph: GamebookGraph
    ) -> Story:
        return await self._stories.save_graph(story_id, user_email, graph)

    async def delete(self, story_id: str, user_email: str) -> None:
        await self._stories.delete(story_id, user_email)
        logger.info("Deleted story %s for %s", story_id, user_email)

    @staticmethod
    def _to_list_item(story: Story) -> StoryListItem:
        narrative_count = sum(
            1 for n in story.graph.nodes if isinstance(n, NarrativeNode)
        )
        first_paragraph = _NO_PARAGRAPH_PLACEHOLDER
        if story.graph.nodes:
            first_paragraph = story.graph.nodes[0].data or first_paragraph
        return StoryListItem(
            id=story.id,
            name=story.name,
            first_paragraph=first_paragraph,
            total_sections=narrative_count,
        )
