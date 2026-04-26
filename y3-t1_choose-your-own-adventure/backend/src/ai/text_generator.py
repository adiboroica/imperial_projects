"""Higher-level LLM operations that build prompts from templates and parse structured replies."""

from __future__ import annotations

import logging
from typing import Any

from pydantic import RootModel, ValidationError

from src.ai.llm import LLMClient
from src.ai.prompts import (
    action_to_second_person_instruction,
    add_actions_prompt,
    has_story_ended_prompt,
    initial_story_prompt,
    narrative_continuation_prompt,
    options_prompt,
    single_action_prompt,
    summarise_instruction,
)
from src.constants import NUM_GENERATION_ATTEMPTS
from src.models.errors import NlpParseError

logger = logging.getLogger(__name__)


class _ActionsList(RootModel[list[str]]):
    """Schema-validate LLM JSON replies — must be a non-empty list of strings."""


def _parse_actions(generated: str) -> list[str] | None:
    """Return cleaned action strings, or None if the response did not match the
    `list[str]` schema or was empty after stripping."""
    try:
        parsed = _ActionsList.model_validate_json(generated)
    except ValidationError:
        return None
    actions = [item.strip() for item in parsed.root if item.strip()]
    return actions or None


class TextGenerator:
    """LLM operations that return domain-shaped values: lists of actions, narrative strings."""

    def __init__(self, llm: LLMClient) -> None:
        self._llm = llm

    async def action_to_second_person(self, action: str) -> str:
        return await self._llm.edit(action, action_to_second_person_instruction())

    async def generate_actions(
        self, full_text: str, num_actions: int = 2
    ) -> list[str]:
        if num_actions <= 1:
            prompt = full_text + "\n\n" + single_action_prompt()
            result = await self._llm.complete(prompt)
            return [result.strip()]

        prompt = full_text + "\n\n" + options_prompt(num_actions)
        for attempt in range(NUM_GENERATION_ATTEMPTS):
            generated = await self._llm.complete(prompt)
            actions = _parse_actions(generated)
            if actions is not None:
                return actions
            logger.warning(
                "TextGenerator.generate_actions parse fail (%d/%d): %s",
                attempt + 1,
                NUM_GENERATION_ATTEMPTS,
                generated,
            )
        raise NlpParseError("Could not parse actions JSON after retries")

    async def add_actions(
        self,
        full_text: str,
        existing_actions: list[str],
        num_new_actions: int = 1,
    ) -> list[str]:
        suffix = add_actions_prompt(existing_actions, num_new_actions)
        prompt = full_text + suffix

        if num_new_actions <= 1:
            result = await self._llm.complete(prompt)
            return [result.strip()]

        for attempt in range(NUM_GENERATION_ATTEMPTS):
            generated = await self._llm.complete(prompt)
            actions = _parse_actions(generated)
            if actions is not None:
                return actions
            logger.warning(
                "TextGenerator.add_actions parse fail (%d/%d): %s",
                attempt + 1,
                NUM_GENERATION_ATTEMPTS,
                generated,
            )
        raise NlpParseError("Could not parse additional actions JSON after retries")

    async def generate_narrative(
        self,
        full_text: str,
        is_ending: bool = False,
        descriptor: str | None = None,
        details: str | None = None,
        style: str | None = None,
    ) -> str:
        prompt = full_text + narrative_continuation_prompt(
            is_ending, descriptor, details, style
        )
        response = await self._llm.complete(prompt)
        if is_ending:
            response += " The end."
        return response

    async def bridge_content(self, from_: str, to: str) -> str:
        for _ in range(NUM_GENERATION_ATTEMPTS):
            middle = await self._llm.insert(f"{from_}\n\n", f"\n\n{to}")
            if middle:
                return middle
        raise NlpParseError("Could not generate bridging content after retries")

    async def has_story_ended(self, full_text: str) -> bool:
        result = await self._llm.complete(full_text + has_story_ended_prompt())
        return result.strip().lower().startswith("yes")

    async def summarise(self, content: str, min_length: int = 600) -> str:
        if len(content) < min_length:
            return content
        prompt = f"{content}\n\n{summarise_instruction()}"
        return await self._llm.complete(prompt)

    async def new_story(self, genre: str, attributes: dict[str, Any]) -> str:
        return await self._llm.complete(initial_story_prompt(genre, attributes))
