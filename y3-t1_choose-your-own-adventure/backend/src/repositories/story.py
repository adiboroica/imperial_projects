"""StoryRepository — the `stories` collection."""

from __future__ import annotations

import logging
from datetime import datetime, timezone

from motor.motor_asyncio import AsyncIOMotorDatabase
from pymongo import ReturnDocument
from pymongo.errors import PyMongoError

from src.models.errors import RepositoryError, StoryNotFound  # noqa: F401
from src.models.graph import GamebookGraph
from src.models.stories import Story

logger = logging.getLogger(__name__)


class StoryRepository:
    """CRUD for a user's stories plus their embedded graph."""

    COLLECTION = "stories"

    def __init__(self, db: AsyncIOMotorDatabase) -> None:
        self._db = db

    @property
    def _coll(self):
        return self._db[self.COLLECTION]

    async def ensure_indexes(self) -> None:
        await self._coll.create_index("userEmail")

    async def create(self, story: Story) -> Story:
        try:
            await self._coll.insert_one(story.model_dump(by_alias=True))
        except PyMongoError as exc:
            logger.exception("StoryRepository.create failed for %s", story.user_email)
            raise RepositoryError("Failed to create story") from exc
        return story

    async def list_for_user(self, user_email: str) -> list[Story]:
        """Return the user's stories ordered by `updatedAt` descending."""
        try:
            cursor = self._coll.find({"userEmail": user_email}).sort("updatedAt", -1)
            docs = await cursor.to_list(length=None)
        except PyMongoError as exc:
            logger.exception("StoryRepository.list_for_user failed for %s", user_email)
            raise RepositoryError("Failed to list stories") from exc
        return [Story.model_validate(doc) for doc in docs]

    async def get_by_id_for_user(
        self, story_id: str, user_email: str
    ) -> Story | None:
        """Return the story or `None` when no document matches the (id, owner) pair.

        Translation to `StoryNotFound` happens at the service layer.
        """
        try:
            doc = await self._coll.find_one({"_id": story_id, "userEmail": user_email})
        except PyMongoError as exc:
            logger.exception("StoryRepository.get_by_id_for_user failed for %s", story_id)
            raise RepositoryError("Failed to load story") from exc
        if doc is None:
            return None
        return Story.model_validate(doc)

    async def update_name(self, story_id: str, user_email: str, name: str) -> Story:
        now = datetime.now(timezone.utc)
        try:
            doc = await self._coll.find_one_and_update(
                {"_id": story_id, "userEmail": user_email},
                {"$set": {"name": name, "updatedAt": now}},
                return_document=ReturnDocument.AFTER,
            )
        except PyMongoError as exc:
            logger.exception("StoryRepository.update_name failed for %s", story_id)
            raise RepositoryError("Failed to rename story") from exc
        if doc is None:
            raise StoryNotFound(story_id)
        return Story.model_validate(doc)

    async def save_graph(
        self, story_id: str, user_email: str, graph: GamebookGraph
    ) -> Story:
        now = datetime.now(timezone.utc)
        try:
            doc = await self._coll.find_one_and_update(
                {"_id": story_id, "userEmail": user_email},
                {
                    "$set": {
                        "graph": graph.to_graph_dict(),
                        "updatedAt": now,
                    }
                },
                return_document=ReturnDocument.AFTER,
            )
        except PyMongoError as exc:
            logger.exception("StoryRepository.save_graph failed for %s", story_id)
            raise RepositoryError("Failed to save graph") from exc
        if doc is None:
            raise StoryNotFound(story_id)
        return Story.model_validate(doc)

    async def delete(self, story_id: str, user_email: str) -> None:
        try:
            result = await self._coll.delete_one(
                {"_id": story_id, "userEmail": user_email}
            )
        except PyMongoError as exc:
            logger.exception("StoryRepository.delete failed for %s", story_id)
            raise RepositoryError("Failed to delete story") from exc
        if result.deleted_count == 0:
            raise StoryNotFound(story_id)
