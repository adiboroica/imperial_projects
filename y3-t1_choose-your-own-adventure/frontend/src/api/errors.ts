/**
 * Typed error classes used by the api layer.
 *
 * `ApiClient` (the HTTP base) translates HTTP statuses into the *generic*
 * errors below — `Unauthenticated`, `NotFound`, `Conflict`, `ServerError`.
 * Per-domain modules (`api/auth.ts`, `api/stories.ts`, …) catch those generic
 * errors and re-throw the *specific* ones (`InvalidCredentials`,
 * `StoryNotFound`, `EmailAlreadyExists`, …) before the slice ever sees them.
 */

// --- Generic (thrown by ApiClient / WSClient) ---

export class ApiError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ApiError";
  }
}

export class Unauthenticated extends ApiError {
  constructor(message = "Not authenticated") {
    super(message);
    this.name = "Unauthenticated";
  }
}

export class NotFound extends ApiError {
  constructor(message = "Resource not found") {
    super(message);
    this.name = "NotFound";
  }
}

export class Conflict extends ApiError {
  constructor(message = "Conflict") {
    super(message);
    this.name = "Conflict";
  }
}

export class ValidationError extends ApiError {
  constructor(public readonly details?: unknown, message = "Validation failed") {
    super(message);
    this.name = "ValidationError";
  }
}

export class ServerError extends ApiError {
  constructor(message = "Server error") {
    super(message);
    this.name = "ServerError";
  }
}

export class NetworkError extends ApiError {
  constructor(message = "Network error") {
    super(message);
    this.name = "NetworkError";
  }
}

export class ParseError extends ApiError {
  constructor(message = "Could not parse response body") {
    super(message);
    this.name = "ParseError";
  }
}

// --- Specific (thrown by per-domain modules after narrowing) ---

export class InvalidCredentials extends ApiError {
  constructor(message = "Email or password is incorrect") {
    super(message);
    this.name = "InvalidCredentials";
  }
}

export class EmailAlreadyExists extends ApiError {
  constructor(message = "Email already registered") {
    super(message);
    this.name = "EmailAlreadyExists";
  }
}

export class StoryNotFound extends ApiError {
  constructor(message = "Story not found") {
    super(message);
    this.name = "StoryNotFound";
  }
}

export class InvalidGraph extends ApiError {
  constructor(public readonly details?: unknown, message = "Graph is invalid") {
    super(message);
    this.name = "InvalidGraph";
  }
}

// --- WS-specific ---

export class WSClosedError extends ApiError {
  constructor(public readonly code: number, message = "WebSocket closed") {
    super(`${message} (code ${code})`);
    this.name = "WSClosedError";
  }
}

export class OpenAIRateLimit extends ApiError {
  constructor(message = "OpenAI rate limit exceeded") {
    super(message);
    this.name = "OpenAIRateLimit";
  }
}

export class OpenAIUnavailable extends ApiError {
  constructor(message = "OpenAI service is unavailable") {
    super(message);
    this.name = "OpenAIUnavailable";
  }
}

export class NlpParseError extends ApiError {
  constructor(message = "Generated response could not be parsed") {
    super(message);
    this.name = "NlpParseError";
  }
}
