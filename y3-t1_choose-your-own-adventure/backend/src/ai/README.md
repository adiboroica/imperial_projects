# AI

LLM and duplicate-detection primitives. No orchestration, no storage, no HTTP — just the infrastructure that `GenerationService` composes.

## 📋 Overview

Four modules:

- **`LLMClient`** (`llm.py`) — async OpenAI wrapper. Owns retry policy, API-key rotation, and translation of OpenAI SDK errors into typed domain errors.
- **`TextGenerator`** (`text_generator.py`) — higher-level LLM interface. Builds prompts from templates, calls `LLMClient`, parses responses into domain-shaped return values (lists of actions, narrative strings).
- **Prompts** (`prompts.py`) — every system and user prompt template used by the app; no prompt string lives outside this file.
- **`Analyser`** (`analyser.py`) — duplicate detection via sentence-transformer embeddings; flags semantically similar branches so `GenerationService` can collapse them into endings.

## 🏗️ Structure

    ai/
    ├── llm.py
    ├── prompts.py
    ├── text_generator.py
    └── analyser.py

## 📐 Design

- **Prompts live in one file** — `prompts.py` holds every system and user template. A prompt string outside this file is a bug; centralisation makes A/B testing, localisation, and drift detection tractable.
- **Retry policy is `LLMClient`'s responsibility** — `RateLimitError` (429) → up to 10 retries with a 3 s back-off; `APIStatusError(503)` and `APIConnectionError` → `OpenAIUnavailable`; other 4xx responses → `OpenAIRequestError` (no retry). Higher layers never implement retries themselves.
- **Key rotation is transparent** — if `OPENAI_API_KEY` is comma-separated, `LLMClient` rotates through the list round-robin per request. The rotation is encapsulated here; callers pass the user's key (or `None` to use the pool) and do not manage state.
- **Stateless, no shared mutable state** — `LLMClient` and `TextGenerator` hold configuration only. `Analyser` lazy-loads the sentence-transformer model once into a process-level singleton; the model is read-only after load.
- **No awareness of storage or HTTP** — `ai/` never sees a graph, a story id, or a MongoDB document. Callers pass raw strings and lists; the layer returns raw strings and lists.
- **Typed errors, not OpenAI SDK exceptions** — `LLMClient` translates `openai.RateLimitError`, `openai.APIStatusError`, and friends into `OpenAIRateLimit`, `OpenAIUnavailable`, `OpenAIRequestError` from `models/errors.py`. Callers never see `openai.*` exception types.

## 🔗 Dependencies

Imports from `models/`, `config.py`, `openai`, `sentence-transformers`, `torch`, and the standard library. Never imports from `routers/`, `services/`, `repositories/`, `db.py`, or `motor`.
