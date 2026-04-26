"""ExportService unit tests."""

from __future__ import annotations

from datetime import datetime, timezone

import pytest

from src.models.errors import StoryNotFound, UnsupportedExportFormat
from src.models.graph import ActionNode, GamebookGraph, NarrativeNode
from src.models.stories import Story
from src.services.export import ExportFormat, ExportService


@pytest.fixture
def export_service(mocked_story_repository):
    return ExportService(mocked_story_repository)


def _make_story(name="My Story", nodes=None) -> Story:
    return Story(
        id="s1",
        user_email="a@b.com",
        name=name,
        graph=GamebookGraph(nodes=nodes or []),
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
    )


# --- Core Functionality ---


@pytest.mark.asyncio
async def test_render_txt_returns_text_bytes(export_service, mocked_story_repository):
    mocked_story_repository.get_by_id_for_user.return_value = _make_story(
        nodes=[
            NarrativeNode(node_id=0, data="Once upon a time", children_ids=[1]),
            ActionNode(node_id=1, data="Open the door"),
        ]
    )
    payload, mime, filename = await export_service.render(
        "s1", "a@b.com", ExportFormat.TXT
    )
    assert isinstance(payload, bytes)
    assert mime == "text/plain"
    assert filename.endswith(".txt")
    text = payload.decode("utf-8")
    assert "My Story" in text
    assert "Once upon a time" in text
    assert "> Open the door" in text


@pytest.mark.asyncio
async def test_render_docx_returns_docx_bytes(export_service, mocked_story_repository):
    mocked_story_repository.get_by_id_for_user.return_value = _make_story()
    payload, mime, filename = await export_service.render(
        "s1", "a@b.com", ExportFormat.DOCX
    )
    assert isinstance(payload, bytes)
    assert payload.startswith(b"PK")  # zip header — DOCX is a zip
    assert mime == (
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    )
    assert filename.endswith(".docx")


@pytest.mark.asyncio
async def test_safe_filename_strips_separators():
    assert ExportService._safe_filename("a/b\\c?d") == "a_b_c_d"
    assert ExportService._safe_filename("My Story 1") == "My Story 1"
    assert ExportService._safe_filename("") == "story"


# --- Edge Cases ---


@pytest.mark.asyncio
async def test_render_unknown_story_raises_story_not_found(
    export_service, mocked_story_repository
):
    mocked_story_repository.get_by_id_for_user.return_value = None
    with pytest.raises(StoryNotFound):
        await export_service.render("missing", "a@b.com", ExportFormat.DOCX)


@pytest.mark.asyncio
async def test_render_empty_story_only_writes_title(
    export_service, mocked_story_repository
):
    mocked_story_repository.get_by_id_for_user.return_value = _make_story()
    payload, _, _ = await export_service.render(
        "s1", "a@b.com", ExportFormat.TXT
    )
    text = payload.decode("utf-8")
    assert "My Story" in text


@pytest.mark.asyncio
async def test_render_renders_ending_marker(
    export_service, mocked_story_repository
):
    mocked_story_repository.get_by_id_for_user.return_value = _make_story(
        nodes=[
            NarrativeNode(node_id=0, data="The end is nigh", is_ending=True),
        ]
    )
    payload, _, _ = await export_service.render(
        "s1", "a@b.com", ExportFormat.TXT
    )
    assert b"[End]" in payload
