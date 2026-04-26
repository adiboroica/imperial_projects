# Store Tests

Test contract for the Redux store wiring and middleware.

## 📋 Overview

Three units. Test files co-located alongside source. `store/` itself contains no slices to test directly; the store smoke test verifies it composes correctly, and the two middleware get behavioural tests.

## ▶️ Running

    npm test -- src/store

See [`../../tests/README.md`](../../tests/README.md) for the full test runner commands.

## 🧪 store smoke

Smoke test that `store.ts` builds a working store from `rootReducer.ts` and the registered middleware.

### Core Functionality

| Area                       | Description                                                              |
| -------------------------- | ------------------------------------------------------------------------ |
| Store builds               | Calling `configureStore({...})` yields a store with the expected shape.   |
| All slices present         | `store.getState()` returns keys for every page and feature slice combined in `rootReducer`. |
| Middleware registered      | `wsMiddleware` and `notificationMiddleware` appear in the middleware chain. |

### Edge Cases

| Case                       | Expected Behaviour                                              |
| -------------------------- | --------------------------------------------------------------- |
| Missing slice in rootReducer | Type check fails at compile time; runtime test catches it via key assertion. |

## 🧪 wsMiddleware

Bridges server-pushed WS frames to Redux dispatches. Has no responsibility for client-initiated request/response (that goes through Promise-based `WSClient`).

### Core Functionality

| Area                                 | Description                                                                 |
| ------------------------------------ | --------------------------------------------------------------------------- |
| `progressUpdate` frame               | Dispatches a graph-slice partial-update action with the embedded snapshot.   |
| Pass-through                         | Actions unrelated to WS pass through unchanged.                              |
| No client-request handling           | A regular thunk dispatch is not intercepted; the Promise client handles it.  |

### Edge Cases

| Case                              | Expected Behaviour                                              |
| --------------------------------- | --------------------------------------------------------------- |
| `progressUpdate` for unknown story | Frame is dropped; no dispatch.                                  |
| Frame arrives before WS connects   | Frame queued (or dropped, per design) without throwing.         |

## 🧪 notificationMiddleware

Listens for `*/rejected` actions and shows a Mantine toast carrying the typed error.

### Core Functionality

| Area                       | Description                                                              |
| -------------------------- | ------------------------------------------------------------------------ |
| Toast on rejection         | Any thunk action ending in `/rejected` triggers a toast.                  |
| Title from error type      | The toast title comes from the typed error's `name` (e.g., "Story not found"). |
| Body from error message    | The toast body comes from the error's `message`.                          |

### Edge Cases

| Case                          | Expected Behaviour                                              |
| ----------------------------- | --------------------------------------------------------------- |
| Action without typed error    | Toast falls back to a generic "Something went wrong" message.   |
| Repeated identical rejections | Mantine de-duplicates by toast id; only one toast surfaces.     |
| Action explicitly suppresses toast | Action carries `meta.silent === true`; middleware skips.    |
