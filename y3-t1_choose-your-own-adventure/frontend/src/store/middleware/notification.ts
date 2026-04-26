/**
 * `notificationMiddleware` — listens for any thunk's `rejected` action and
 * surfaces a Mantine toast with the typed error. Slices stay focused on
 * state; they do not know the user-facing toast machinery exists.
 */

import { isRejected, type Middleware } from "@reduxjs/toolkit";
import { notifications } from "@mantine/notifications";

const FRIENDLY_TITLES: Record<string, string> = {
  InvalidCredentials: "Invalid credentials",
  EmailAlreadyExists: "Email already registered",
  StoryNotFound: "Story not found",
  InvalidGraph: "Invalid graph",
  Unauthenticated: "Not signed in",
  OpenAIRateLimit: "OpenAI rate limit",
  OpenAIUnavailable: "OpenAI unavailable",
  NlpParseError: "Generation failed",
  NetworkError: "Network problem",
  ServerError: "Server error",
  ParseError: "Server error",
};

// Thunks whose rejection is part of the normal control flow — failing them
// is expected, the slice handles the state, and a toast would be noise.
const SILENT_THUNK_TYPES: ReadonlySet<string> = new Set([
  // `session()` is the bootstrap probe; a 401 means "not signed in" and the
  // route guard handles redirection to /login. No user-visible error.
  "auth/session/rejected",
]);

const errorTitle = (
  payload: unknown,
  errorName: string | undefined,
): string => {
  // Thunks built with `rejectWithValue(errorName(err))` put the typed name
  // on `action.payload`; thunks that throw raw expose it on `action.error`.
  if (typeof payload === "string" && FRIENDLY_TITLES[payload]) {
    return FRIENDLY_TITLES[payload];
  }
  if (errorName && FRIENDLY_TITLES[errorName]) {
    return FRIENDLY_TITLES[errorName];
  }
  if (typeof payload === "string" && payload) return payload;
  if (errorName) return errorName;
  return "Something went wrong";
};

const notificationMiddleware: Middleware = () => (next) => (action) => {
  const result = next(action);
  if (!isRejected(action)) return result;

  if (SILENT_THUNK_TYPES.has(action.type)) return result;

  // Per-action escape hatch — `dispatch(thunk(args, { silent: true }))`.
  if ((action.meta as { silent?: boolean } | undefined)?.silent) return result;

  const message =
    action.error?.message && action.error.message !== "Rejected"
      ? action.error.message
      : "An unexpected error occurred.";

  notifications.show({
    color: "red",
    title: errorTitle(action.payload, action.error?.name),
    message,
  });
  return result;
};

export default notificationMiddleware;
