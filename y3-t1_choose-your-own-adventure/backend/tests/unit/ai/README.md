# AI Unit Tests

Unit-test coverage for the LLM client, text generator, and duplicate analyser in `src/ai/`. Tests mock at each layer's outer boundary: `LLMClient` mocks the `openai` async client, `TextGenerator` mocks `LLMClient`, and `Analyser` mocks the sentence-transformer model.

## 📋 Overview

Three modules. No real OpenAI calls, no real model downloads. Prompt templates from `prompts.py` are exercised as part of `TextGenerator` tests rather than tested in isolation — a template is only meaningful when rendered with its arguments.

## ▶️ Running

See [`../README.md`](../README.md#-running) for the test commands.

## 🧪 LLMClient

Covers the async OpenAI wrapper: request dispatch, retry behaviour, API-key rotation, and translation of OpenAI SDK errors into typed domain errors. The `openai.AsyncOpenAI` client is mocked.

### Core Functionality

| Area                      | Description                                                                              |
| ------------------------- | ---------------------------------------------------------------------------------------- |
| Basic completion          | Sends the prompt and returns the response string.                                        |
| User-supplied key         | When a key is passed in, it is used for that request and the pool is not touched.        |
| Key pool rotation         | With `OPENAI_API_KEY` comma-separated, successive calls rotate round-robin.              |
| Retry on `RateLimitError` | Retries up to ten times with a three-second back-off before surfacing.                   |
| Error translation         | `APIStatusError(503)` → `OpenAIUnavailable`; `APIConnectionError` → `OpenAIUnavailable`. |

### Edge Cases

| Case                                    | Expected Behaviour                                        |
| --------------------------------------- | --------------------------------------------------------- |
| All ten retries exhausted on 429        | Raises `OpenAIRateLimit` to the caller.                   |
| `APIStatusError(400)` (other 4xx)       | Raises `OpenAIRequestError`; no retry.                    |
| Empty key pool and no user-supplied key | Raises `OpenAIConfigurationError` before calling the SDK. |
| Key rotation across concurrent callers  | Round-robin index advances exactly once per request.      |

## 🧪 TextGenerator

Covers the prompt-building and response-parsing layer. Tests supply a mock `LLMClient` with scripted responses and assert on the parsed return values.

### Core Functionality

| Area                      | Description                                                                             |
| ------------------------- | --------------------------------------------------------------------------------------- |
| `generate_actions`        | Composes the actions prompt, parses the JSON list, returns `numActions` strings.        |
| `add_actions`             | Injects the existing actions into the prompt so the LLM does not repeat them.           |
| `generate_narrative`      | Composes the narrative prompt with optional `descriptor` / `details` / `style` flags.   |
| `action_to_second_person` | Rewrites a third-person action into a "You …" phrase.                                   |
| `bridge_content`          | Produces bridge text that links two passages.                                           |
| Prompt template usage     | Every prompt string originates in `prompts.py`; no prompt literal lives in this module. |

### Edge Cases

| Case                                                    | Expected Behaviour                                             |
| ------------------------------------------------------- | -------------------------------------------------------------- |
| Response is not valid JSON                              | Retries the call; after three failures raises `NlpParseError`. |
| Response parses but returns the wrong number of actions | Retries; after three failures raises `NlpParseError`.          |
| Response is empty                                       | Retries; after three failures raises `NlpParseError`.          |
| `LLMClient` raises `OpenAIRateLimit`                    | Propagates unchanged; no catch-and-retry at this layer.        |

## 🧪 Analyser

Covers semantic-similarity duplicate detection. The sentence-transformer model is replaced with a stub that returns scripted embeddings.

### Core Functionality

| Area                            | Description                                                                |
| ------------------------------- | -------------------------------------------------------------------------- |
| `is_duplicate` (short sentence) | Returns `True` when mean cosine similarity meets the short-text threshold. |
| `is_duplicate` (multi-sentence) | Returns `True` when the per-sentence similarity ratio meets the threshold. |
| Not duplicate                   | Returns `False` when similarity falls below the threshold.                 |
| Whitespace normalisation        | Leading, trailing, and repeated whitespace is normalised before embedding. |
| Model singleton                 | First call loads the model; subsequent calls reuse the cached instance.    |

### Edge Cases

| Case                              | Expected Behaviour                                     |
| --------------------------------- | ------------------------------------------------------ |
| Empty `new_text`                  | Returns `False`; no embedding call.                    |
| Empty `existing_texts`            | Returns `False`; no embedding call.                    |
| Single-sentence vs multi-sentence | Branches into the correct threshold rule.              |
| Non-ASCII input                   | Embeds correctly; does not strip or mangle characters. |
