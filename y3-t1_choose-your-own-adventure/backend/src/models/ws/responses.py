"""Server → client WS payload models."""

from __future__ import annotations

from pydantic import BaseModel, Field

from src.models.graph import GamebookGraph


class RequestCompletePayload(BaseModel):
    """`type=requestComplete` — operation finished; payload carries the full updated graph."""

    graph: GamebookGraph


class ProgressUpdatePayload(BaseModel):
    """`type=progressUpdate` — partial update during `generateMany`."""

    graph: GamebookGraph
    nodes_generated: int = Field(default=0, alias="nodesGenerated", ge=0)
    percentage: float = Field(default=0.0, ge=0.0, le=100.0)

    model_config = {"populate_by_name": True}


class ErrorPayload(BaseModel):
    """`type=error` — generic server-side failure."""

    message: str


class RateLimitErrorPayload(BaseModel):
    """`type=rateLimitError` — OpenAI returned 429."""

    message: str = "OpenAI rate limit exceeded; please retry after a backoff."


class OpenAIErrorPayload(BaseModel):
    """`type=openaiError` — OpenAI unavailable (503) or connection failure."""

    message: str = "OpenAI service is temporarily unavailable."


class NlpParseErrorPayload(BaseModel):
    """`type=nlpParseError` — generated response could not be parsed after retries."""

    message: str = "The model returned a response we could not parse after retries."
