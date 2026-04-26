"""Duplicate detection via sentence-transformer embeddings."""

from __future__ import annotations

import re

from sentence_transformers import SentenceTransformer, util

_MODEL_NAME = "all-MiniLM-L6-v2"
_WHITESPACE_RE = re.compile(r"\n\s*")
_SIMILARITY_THRESHOLD = 0.85
_MAJORITY_THRESHOLD = 0.5

_model: SentenceTransformer | None = None


def _get_model() -> SentenceTransformer:
    global _model
    if _model is None:
        _model = SentenceTransformer(_MODEL_NAME)
    return _model


def _normalise(text: str) -> str:
    return _WHITESPACE_RE.sub("", text)


def _split_sentences(text: str) -> list[str]:
    return [s.strip() for s in _normalise(text).split(".") if s.strip()]


def is_duplicate(text_one: str, text_two: str) -> bool:
    """True when two action / narrative passages are semantically near-identical.

    Short texts (<=2 sentences each) compare by mean of the per-sentence max
    similarities; longer texts require a majority of sentences to clear the
    similarity threshold.
    """
    sentences_one = _split_sentences(text_one)
    sentences_two = _split_sentences(text_two)
    if not sentences_one or not sentences_two:
        return False

    model = _get_model()
    emb_one = model.encode(sentences_one, convert_to_tensor=True)
    emb_two = model.encode(sentences_two, convert_to_tensor=True)
    cosine_scores = util.pytorch_cos_sim(emb_one, emb_two)
    max_scores = cosine_scores.max(dim=1).values

    if len(sentences_one) <= 2 and len(sentences_two) <= 2:
        return float(max_scores.mean().item()) >= _SIMILARITY_THRESHOLD
    return (
        float((max_scores >= _SIMILARITY_THRESHOLD).float().mean().item())
        >= _MAJORITY_THRESHOLD
    )
