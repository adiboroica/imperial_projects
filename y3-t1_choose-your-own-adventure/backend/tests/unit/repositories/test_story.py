"""StoryRepository unit tests against an in-memory mongomock-motor database."""

from __future__ import annotations

import asyncio
from datetime import datetime, timedelta, timezone

import pytest
from mongomock_motor import AsyncMongoMockClient

from src.models.errors import StoryNotFound
from src.models.graph import GamebookGraph, NarrativeNode
from src.models.stories import Story
from src.repositories.story import StoryRepository


@pytest.fixture
async def repo():
    db = AsyncMongoMockClient()["cyoa_test"]
    r = StoryRepository(db)
    await r.ensure_indexes()
    return r


def _story(
    *,
    id_: str = "s1",
    user_email: str = "a@b.com",
    name: str = "Story",
    updated_at: datetime | None = None,
) -> Story:
    now = updated_at or datetime.now(timezone.utc)
    return Story(
        id=id_,
        user_email=user_email,
        name=name,
        graph=GamebookGraph(),
        created_at=now,
        updated_at=now,
    )


# --- Core Functionality ---


@pytest.mark.asyncio
async def test_create_and_get_round_trip(repo):
    s = _story()
    await repo.create(s)
    fetched = await repo.get_by_id_for_user("s1", "a@b.com")
    assert fetched is not None
    assert fetched.id == "s1"


@pytest.mark.asyncio
async def test_list_for_user_returns_only_matching_owner(repo):
    await repo.create(_story(id_="s1", user_email="a@b.com"))
    await repo.create(_story(id_="s2", user_email="b@b.com"))
    result = await repo.list_for_user("a@b.com")
    assert [s.id for s in result] == ["s1"]


@pytest.mark.asyncio
async def test_list_for_user_orders_by_updated_at_desc(repo):
    older = datetime.now(timezone.utc) - timedelta(days=1)
    newer = datetime.now(timezone.utc)
    await repo.create(_story(id_="s-old", updated_at=older))
    await repo.create(_story(id_="s-new", updated_at=newer))
    result = await repo.list_for_user("a@b.com")
    assert [s.id for s in result] == ["s-new", "s-old"]


@pytest.mark.asyncio
async def test_update_name_returns_updated_story(repo):
    await repo.create(_story())
    updated = await repo.update_name("s1", "a@b.com", "Renamed")
    assert updated.name == "Renamed"


@pytest.mark.asyncio
async def test_save_graph_replaces_graph_field(repo):
    await repo.create(_story())
    new_graph = GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")])
    saved = await repo.save_graph("s1", "a@b.com", new_graph)
    assert len(saved.graph.nodes) == 1


@pytest.mark.asyncio
async def test_delete_removes_story(repo):
    await repo.create(_story())
    await repo.delete("s1", "a@b.com")
    assert await repo.get_by_id_for_user("s1", "a@b.com") is None


# --- Edge Cases ---


@pytest.mark.asyncio
async def test_get_for_unknown_id_returns_none(repo):
    assert await repo.get_by_id_for_user("missing", "a@b.com") is None


@pytest.mark.asyncio
async def test_get_for_foreign_user_returns_none(repo):
    await repo.create(_story(id_="s1", user_email="a@b.com"))
    assert await repo.get_by_id_for_user("s1", "intruder@b.com") is None


@pytest.mark.asyncio
async def test_update_name_unknown_raises_story_not_found(repo):
    with pytest.raises(StoryNotFound):
        await repo.update_name("missing", "a@b.com", "Renamed")


@pytest.mark.asyncio
async def test_save_graph_unknown_raises_story_not_found(repo):
    with pytest.raises(StoryNotFound):
        await repo.save_graph("missing", "a@b.com", GamebookGraph())


@pytest.mark.asyncio
async def test_delete_unknown_raises_story_not_found(repo):
    with pytest.raises(StoryNotFound):
        await repo.delete("missing", "a@b.com")
