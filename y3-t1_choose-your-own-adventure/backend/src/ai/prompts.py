"""Every system and user prompt template used by the app. No prompt string lives outside this file."""

from __future__ import annotations

from typing import Any

# --- System instructions ---

GAMEBOOK_WRITER_SYSTEM = (
    "You are a creative fiction writer specializing in adventure gamebook "
    "stories written in second person. Continue the story naturally. "
    "Output only the story text, no commentary or markdown formatting."
)

BRIDGE_WRITER_SYSTEM = (
    "You are a creative fiction writer. Write a passage that "
    "naturally connects the given prefix text to the suffix text. "
    "Output ONLY the connecting text, nothing else."
)

TEXT_EDITOR_SYSTEM = (
    "You are a text editor. Apply the given instruction to modify "
    "the provided text. Output ONLY the modified text, nothing else."
)


# --- Builders ---


def options_prompt(num_options: int) -> str:
    """Suffix that asks for N action choices in JSON format."""
    return (
        f"Generate {num_options} different choices for action in gamebook style "
        f"as a JSON list of strings:"
    )


def single_action_prompt() -> str:
    return "Generate only 1 choice for action in gamebook style:"


def add_actions_prompt(existing_actions: list[str], num_new: int) -> str:
    """Suffix asking for `num_new` more action choices in addition to the existing list."""
    listing = "\n".join(existing_actions)
    base = f"\n\nYou already have the following choices for action: {listing}"
    if num_new <= 1:
        return base + "\n\nAdd another choice for action: "
    return (
        base
        + f"\n\nAdd {num_new} more choices for action as a JSON list of strings: "
    )


def narrative_continuation_prompt(
    is_ending: bool,
    descriptor: str | None,
    details: str | None,
    style: str | None,
) -> str:
    """Suffix that asks for a narrative continuation (or ending)."""
    parts: list[str] = []
    if descriptor is not None:
        kind = "ending" if is_ending else "continuation"
        parts.append(f"Generate a {descriptor} {kind}.")
    elif is_ending:
        parts.append("Generate an ending.")

    if details is not None:
        parts.append(f"Important details: {details}")
    if style is not None:
        parts.append(f"Writing style: {style}")

    parts.append("Result: ")
    return "\n\n" + "\n\n".join(parts)


def has_story_ended_prompt() -> str:
    return "\n\nDid the story end yet (Yes | No)?"


def initial_story_prompt(genre: str, attributes: dict[str, Any]) -> str:
    """The seed prompt for `generateInitial`."""
    description = "; ".join(f'{k}: "{v}"' for k, v in attributes.items())
    if description:
        return (
            f"Write an adventure story in the {genre} genre with {description} "
            f"in second person:"
        )
    return f"Write an adventure story in the {genre} genre in second person:"


def summarise_instruction() -> str:
    return (
        "Summarise this story in detail as JSON with all events "
        "(in form {event1: ..., event2: ...}) and final state:"
    )


def action_to_second_person_instruction() -> str:
    return "Rewrite this as 'You choose ...'"
