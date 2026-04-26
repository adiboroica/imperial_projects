"""Analyser unit tests with the SentenceTransformer model mocked."""

from __future__ import annotations

from unittest.mock import MagicMock, patch

import pytest


@pytest.fixture(autouse=True)
def reset_module_singleton():
    """Reset the cached SentenceTransformer between tests."""
    from src.ai import analyser as analyser_mod

    analyser_mod._model = None
    yield
    analyser_mod._model = None


def _stub_with_scores(scores: list[list[float]]):
    """Patch `_get_model` and `pytorch_cos_sim` so similarity returns canned values."""
    import torch

    from src.ai import analyser as analyser_mod

    model = MagicMock()
    # `encode` just needs to return a tensor of plausible shape.
    model.encode = MagicMock(
        side_effect=lambda texts, convert_to_tensor=False: torch.zeros(
            (len(texts), 3)
        ),
    )
    cos_tensor = torch.tensor(scores)
    return patch.object(analyser_mod, "_get_model", return_value=model), patch.object(
        analyser_mod.util, "pytorch_cos_sim", return_value=cos_tensor
    )


# --- Helpers ---


def test_split_sentences_normalises_whitespace():
    from src.ai.analyser import _split_sentences

    assert _split_sentences("First.\n  Second.\nThird.") == [
        "First",
        "Second",
        "Third",
    ]


def test_split_sentences_drops_empty_segments():
    from src.ai.analyser import _split_sentences

    assert _split_sentences("..a.. .b.") == ["a", "b"]


# --- Core Functionality ---


def test_is_duplicate_short_text_above_threshold_returns_true():
    """Short text (<=2 sentences each side) uses mean of per-row max — needs >= 0.85."""
    get_model_patch, cos_sim_patch = _stub_with_scores([[0.95]])
    with get_model_patch, cos_sim_patch:
        from src.ai.analyser import is_duplicate

        assert is_duplicate("walk", "stroll") is True


def test_is_duplicate_short_text_below_threshold_returns_false():
    get_model_patch, cos_sim_patch = _stub_with_scores([[0.40]])
    with get_model_patch, cos_sim_patch:
        from src.ai.analyser import is_duplicate

        assert is_duplicate("walk", "fly") is False


def test_is_duplicate_long_text_majority_above_threshold_returns_true():
    """Long text uses majority rule: >= 50% of sentences must clear 0.85."""
    # Three sentences each side; 2/3 above threshold → majority.
    scores = [
        [0.95, 0.10, 0.10],
        [0.10, 0.95, 0.10],
        [0.10, 0.10, 0.40],
    ]
    get_model_patch, cos_sim_patch = _stub_with_scores(scores)
    with get_model_patch, cos_sim_patch:
        from src.ai.analyser import is_duplicate

        assert (
            is_duplicate(
                "First. Second. Third.", "Other one. Other two. Other three."
            )
            is True
        )


def test_is_duplicate_long_text_minority_above_threshold_returns_false():
    """1/3 above 0.85 → below the 50% majority — not duplicate."""
    scores = [
        [0.95, 0.10, 0.10],
        [0.10, 0.40, 0.10],
        [0.10, 0.10, 0.40],
    ]
    get_model_patch, cos_sim_patch = _stub_with_scores(scores)
    with get_model_patch, cos_sim_patch:
        from src.ai.analyser import is_duplicate

        assert (
            is_duplicate(
                "First. Second. Third.", "Other one. Other two. Other three."
            )
            is False
        )


# --- Edge Cases ---


def test_is_duplicate_empty_first_returns_false_without_calling_model():
    from src.ai.analyser import is_duplicate

    assert is_duplicate("", "non-empty") is False


def test_is_duplicate_empty_second_returns_false_without_calling_model():
    from src.ai.analyser import is_duplicate

    assert is_duplicate("non-empty", "") is False


def test_is_duplicate_whitespace_only_returns_false():
    from src.ai.analyser import is_duplicate

    assert is_duplicate("   \n   ", "anything") is False


def test_model_is_loaded_once_and_cached():
    """First call loads the model; subsequent calls reuse it."""
    from src.ai import analyser as analyser_mod

    with patch("src.ai.analyser.SentenceTransformer") as transformer_cls:
        transformer_cls.return_value = MagicMock()
        analyser_mod._get_model()
        analyser_mod._get_model()
        # Loaded exactly once.
        assert transformer_cls.call_count == 1
