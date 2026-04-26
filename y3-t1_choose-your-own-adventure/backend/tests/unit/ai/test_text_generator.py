"""TextGenerator unit tests with LLMClient mocked."""

from __future__ import annotations

from unittest.mock import AsyncMock

import pytest

from src.ai.text_generator import TextGenerator
from src.models.errors import NlpParseError


@pytest.fixture
def llm():
    return AsyncMock()


@pytest.fixture
def text_gen(llm):
    return TextGenerator(llm)


# --- Core Functionality ---


@pytest.mark.asyncio
async def test_generate_actions_parses_json_list(text_gen, llm):
    llm.complete.return_value = '["go left", "go right"]'
    actions = await text_gen.generate_actions("text", num_actions=2)
    assert actions == ["go left", "go right"]


@pytest.mark.asyncio
async def test_generate_actions_single_returns_raw_string(text_gen, llm):
    llm.complete.return_value = "  open the door  "
    actions = await text_gen.generate_actions("text", num_actions=1)
    assert actions == ["open the door"]


@pytest.mark.asyncio
async def test_add_actions_includes_existing_in_prompt(text_gen, llm):
    llm.complete.return_value = '["new option"]'
    actions = await text_gen.add_actions("text", ["existing"], num_new_actions=2)
    assert actions == ["new option"]
    prompt = llm.complete.await_args.args[0]
    assert "existing" in prompt


@pytest.mark.asyncio
async def test_generate_narrative_appends_options(text_gen, llm):
    llm.complete.return_value = "narrative text"
    out = await text_gen.generate_narrative(
        "previous", descriptor="dark", details="rainy", style="terse"
    )
    assert out == "narrative text"
    prompt = llm.complete.await_args.args[0]
    assert "dark" in prompt
    assert "rainy" in prompt
    assert "terse" in prompt


@pytest.mark.asyncio
async def test_generate_narrative_ending_appends_marker(text_gen, llm):
    llm.complete.return_value = "the conclusion"
    out = await text_gen.generate_narrative("previous", is_ending=True)
    assert out.endswith("The end.")


@pytest.mark.asyncio
async def test_action_to_second_person_uses_edit(text_gen, llm):
    llm.edit.return_value = "You choose to run"
    out = await text_gen.action_to_second_person("run")
    assert out == "You choose to run"
    llm.edit.assert_awaited_once()


@pytest.mark.asyncio
async def test_bridge_content_uses_insert(text_gen, llm):
    llm.insert.return_value = "bridge"
    out = await text_gen.bridge_content("from", "to")
    assert out == "bridge"


@pytest.mark.asyncio
async def test_has_story_ended_yes(text_gen, llm):
    llm.complete.return_value = "Yes"
    assert await text_gen.has_story_ended("...") is True


@pytest.mark.asyncio
async def test_has_story_ended_no(text_gen, llm):
    llm.complete.return_value = "No"
    assert await text_gen.has_story_ended("...") is False


@pytest.mark.asyncio
async def test_new_story_calls_complete(text_gen, llm):
    llm.complete.return_value = "Once upon a time…"
    out = await text_gen.new_story("fantasy", {"hero": "elf"})
    assert "Once" in out


# --- Edge Cases ---


@pytest.mark.asyncio
async def test_generate_actions_invalid_json_raises_after_retries(text_gen, llm):
    llm.complete.return_value = "not json"
    with pytest.raises(NlpParseError):
        await text_gen.generate_actions("text", num_actions=2)


@pytest.mark.asyncio
async def test_bridge_content_empty_response_raises_after_retries(text_gen, llm):
    llm.insert.return_value = ""
    with pytest.raises(NlpParseError):
        await text_gen.bridge_content("from", "to")
