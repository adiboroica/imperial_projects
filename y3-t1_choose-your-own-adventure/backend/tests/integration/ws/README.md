# WebSocket Integration Tests

End-to-end coverage for the `/ws` full-duplex channel. Each test drives a real FastAPI app with `LLMClient` mocked; canned OpenAI responses are scripted on the fixture before the socket opens.

## 📋 Overview

One table covering every workflow. Both connection-level cases (auth, origin, malformed frames) and message-level cases (payload validation, OpenAI errors surfaced as typed frames) sit in the same table, distinguished by the `Expected` column.

## ▶️ Running

    pytest tests/integration/ws

## 🧪 Workflows

| Case                                      | Expected                                                                     |
| ----------------------------------------- | ---------------------------------------------------------------------------- |
| Connect with a valid session cookie       | Socket opens.                                                                |
| Connect without a session cookie          | Closed with code `4001`.                                                     |
| Connect with a mismatched `Origin` header | Closed with code `4003`.                                                     |
| `initialStory` with a valid payload       | `requestComplete` frame carrying the root narrative and its action children. |
| `generateActions` on a narrative node     | `requestComplete` frame with N new action children.                          |
| `generateMany` with depth > 0             | Multiple `progressUpdate` frames followed by `requestComplete`.              |
| Frame missing `requestId`                 | Closed with code `1003`.                                                     |
| Frame with an unknown `type`              | Closed with code `1003`.                                                     |
| Client `type` with an invalid payload     | Closed with code `1003`.                                                     |
| OpenAI returns 429                        | `rateLimitError` frame; same `requestId` echoed.                             |
| OpenAI returns 503                        | `openaiError` frame.                                                         |
| `TextGenerator` exhausts parse retries    | `nlpParseError` frame.                                                       |
