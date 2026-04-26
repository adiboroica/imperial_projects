"""Domain exception classes raised by services and translated to HTTP / WS errors at the boundary."""

from __future__ import annotations


class DomainError(Exception):
    """Base for every domain-layer exception."""


# --- Auth ---


class InvalidCredentials(DomainError):
    """Email or password did not match a stored account."""


class EmailAlreadyExists(DomainError):
    """Signup attempted with an email that already has an account."""


class Unauthenticated(DomainError):
    """No valid session cookie on a protected request."""


class SessionNotFound(DomainError):
    """No session record matches the given id."""


class SessionExpired(DomainError):
    """Session lookup found a record whose `expires_at` is in the past."""


class UserNotFound(DomainError):
    """No user record matches the given email."""


# --- Stories ---


class StoryNotFound(DomainError):
    """No story with the given id, or not owned by the requesting user."""


class InvalidGraph(DomainError):
    """Graph payload failed structural validation."""


# --- Graph ---


class CycleError(DomainError):
    """A `connect_nodes` operation would have created a cycle."""


class NodeNotFound(DomainError):
    """A graph operation referenced a node id that does not exist."""


class InvalidNodeType(DomainError):
    """An operation was applied to the wrong kind of node (e.g. expanding actions on an action node)."""


class InvalidNodeConnection(DomainError):
    """A node-connection operation is structurally invalid (e.g. source == target)."""


# --- API key ---


class ApiKeyCorrupted(DomainError):
    """A stored API-key cipher could not be decrypted (likely after `ENCRYPTION_KEY` rotation)."""


# --- AI / OpenAI ---


class OpenAIRateLimit(DomainError):
    """OpenAI returned 429; caller may retry after backoff."""


class OpenAIUnavailable(DomainError):
    """OpenAI returned 503 or the connection failed."""


class OpenAIRequestError(DomainError):
    """OpenAI returned a 4xx other than 429; not retried."""


class OpenAIConfigurationError(DomainError):
    """No API key is configured (empty pool and no user-supplied key)."""


class NlpParseError(DomainError):
    """LLM response could not be parsed after the configured retry count."""


# --- Repositories ---


class RepositoryError(DomainError):
    """Generic repository-layer failure."""


# --- Export ---


class UnsupportedExportFormat(DomainError):
    """Requested export format is not one of the supported values."""
