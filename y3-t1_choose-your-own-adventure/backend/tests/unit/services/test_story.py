"""StoryService unit tests."""

from __future__ import annotations

from datetime import datetime, timezone

import pytest

from src.models.errors import StoryNotFound
from src.models.graph import GamebookGraph, NarrativeNode
from src.models.stories import Story
from src.services.story import StoryService


@pytest.fixture
def story_service(mocked_story_repository):
    return StoryService(mocked_story_repository)


def _make_story(name="Story", graph=None) -> Story:
    return Story(
        id="s1",
        user_email="a@b.com",
        name=name,
        graph=graph or GamebookGraph(),
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
    )


# --- Core Functionality ---


@pytest.mark.asyncio
async def test_create_persists_new_story(story_service, mocked_story_repository):
    story = await story_service.create("a@b.com", name="My Story")
    assert story.user_email == "a@b.com"
    assert story.name == "My Story"
    mocked_story_repository.create.assert_awaited_once()


@pytest.mark.asyncio
async def test_list_returns_user_stories_as_listitems(
    story_service, mocked_story_repository
):
    s = _make_story(graph=GamebookGraph(nodes=[NarrativeNode(node_id=0, data="root")]))
    mocked_story_repository.list_for_user.return_value = [s]
    result = await story_service.list_for_user("a@b.com")
    assert len(result) == 1
    assert result[0].id == "s1"
    assert result[0].first_paragraph == "root"
    assert result[0].total_sections == 1


@pytest.mark.asyncio
async def test_get_by_id_returns_story_response(
    story_service, mocked_story_repository
):
    mocked_story_repository.get_by_id_for_user.return_value = _make_story()
    response = await story_service.get_by_id("s1", "a@b.com")
    assert response.id == "s1"


@pytest.mark.asyncio
async def test_rename_calls_repo(story_service, mocked_story_repository):
    mocked_story_repository.update_name.return_value = _make_story(name="Renamed")
    await story_service.rename("s1", "a@b.com", "Renamed")
    mocked_story_repository.update_name.assert_awaited_once_with(
        "s1", "a@b.com", "Renamed"
    )


@pytest.mark.asyncio
async def test_save_graph_calls_repo(story_service, mocked_story_repository):
    g = GamebookGraph()
    mocked_story_repository.save_graph.return_value = _make_story()
    await story_service.save_graph("s1", "a@b.com", g)
    mocked_story_repository.save_graph.assert_awaited_once()


@pytest.mark.asyncio
async def test_delete_calls_repo(story_service, mocked_story_repository):
    await story_service.delete("s1", "a@b.com")
    mocked_story_repository.delete.assert_awaited_once_with("s1", "a@b.com")


# --- Edge Cases ---


@pytest.mark.asyncio
async def test_get_by_id_unknown_raises_story_not_found(
    story_service, mocked_story_repository
):
    mocked_story_repository.get_by_id_for_user.return_value = None
    with pytest.raises(StoryNotFound):
        await story_service.get_by_id("missing", "a@b.com")


@pytest.mark.asyncio
async def test_get_full_unknown_raises_story_not_found(
    story_service, mocked_story_repository
):
    mocked_story_repository.get_by_id_for_user.return_value = None
    with pytest.raises(StoryNotFound):
        await story_service.get_full("missing", "a@b.com")


@pytest.mark.asyncio
async def test_list_with_empty_graph_returns_placeholder(
    story_service, mocked_story_repository
):
    mocked_story_repository.list_for_user.return_value = [_make_story()]
    result = await story_service.list_for_user("a@b.com")
    assert "ATTENTION" in result[0].first_paragraph
    assert result[0].total_sections == 0
