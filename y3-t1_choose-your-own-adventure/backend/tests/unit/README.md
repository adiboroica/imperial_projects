# Unit Tests

Pytest-based unit tests for every code unit in `src/`. No network, no real MongoDB; dependencies are mocked or supplied with test doubles.

## 📋 Overview

One test file per code unit, organised by layer:

- **[`services/`](services/README.md)** — `AuthService`, `StoryService`, `ApiKeyService`, `GenerationService`, `ExportService`.
- **[`repositories/`](repositories/README.md)** — `UserRepository`, `SessionRepository`, `StoryRepository`.
- **[`ai/`](ai/README.md)** — `LLMClient`, `TextGenerator`, `Analyser`.
- **[`models/`](models/README.md)** — `GamebookGraph` and Pydantic request/response validators.

Each sub-README has a `Core Functionality` + `Edge Cases` table per unit.

## ▶️ Running

    pytest tests/unit                    # all unit tests
    pytest tests/unit/services           # services only
    pytest tests/unit/repositories       # repositories only
    pytest tests/unit/ai                 # ai only
    pytest tests/unit/models             # models only
    pytest tests/unit/services/test_auth.py           # single file

## 📐 Conventions

- **One test file per code unit** — `tests/unit/services/test_auth.py` covers `src/services/auth.py`. The test tree mirrors `src/`.
- **No real infrastructure** — MongoDB, OpenAI, and `sentence-transformers` are replaced with test doubles.
- **Mock at the interface seam** — services mock their repositories; repositories mock the Motor collection; `LLMClient` mocks the `openai` async client. Each test pins the contract at its layer boundary.
- **Async-first** — every test that exercises an async function is itself async (`@pytest.mark.asyncio`); no `asyncio.run()` inside test bodies.

## 📂 Sub-Module Documentation

- [`services/README.md`](services/README.md) — service unit-test coverage.
- [`repositories/README.md`](repositories/README.md) — repository unit-test coverage.
- [`ai/README.md`](ai/README.md) — AI primitive unit-test coverage.
- [`models/README.md`](models/README.md) — model unit-test coverage.
