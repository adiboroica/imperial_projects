/**
 * Typed HTTP client. The only caller of `fetch` in the entire frontend.
 *
 * Maps HTTP statuses to *generic* typed errors. Per-domain modules narrow them
 * to specific names before they reach a slice.
 */

import {
  Conflict,
  NetworkError,
  NotFound,
  ParseError,
  ServerError,
  Unauthenticated,
  ValidationError,
} from "../errors";

const API_BASE: string =
  (import.meta.env.VITE_API_URL as string | undefined) ?? "/api";

const stripTrailingSlash = (s: string) => (s.endsWith("/") ? s.slice(0, -1) : s);

const buildUrl = (path: string) =>
  `${stripTrailingSlash(API_BASE)}${path.startsWith("/") ? path : `/${path}`}`;

type Method = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";

type RequestOptions = {
  body?: unknown;
  query?: Record<string, string | number | boolean | undefined>;
};

const buildQuery = (query: RequestOptions["query"]): string => {
  if (!query) return "";
  const pairs = Object.entries(query)
    .filter(([, v]) => v !== undefined)
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(String(v))}`);
  return pairs.length ? `?${pairs.join("&")}` : "";
};

const parseJson = async (response: Response): Promise<unknown> => {
  const text = await response.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    throw new ParseError(`Expected JSON, got: ${text.slice(0, 80)}`);
  }
};

const translateError = async (response: Response): Promise<never> => {
  let body: unknown = null;
  try {
    body = await parseJson(response);
  } catch {
    /* parse failure is not fatal here */
  }

  const status = response.status;
  if (status === 401) throw new Unauthenticated();
  if (status === 404) throw new NotFound();
  if (status === 409) throw new Conflict();
  if (status === 422) throw new ValidationError(body, "Validation failed");
  if (status >= 500) throw new ServerError(`Server error ${status}`);
  throw new ServerError(`Unexpected status ${status}`);
};

const request = async <T>(
  method: Method,
  path: string,
  options: RequestOptions = {},
): Promise<T> => {
  const init: RequestInit = {
    method,
    credentials: "include",
    headers: { "Content-Type": "application/json" },
  };
  if (options.body !== undefined) {
    init.body = JSON.stringify(options.body);
  }
  let response: Response;
  try {
    response = await fetch(buildUrl(path) + buildQuery(options.query), init);
  } catch (err) {
    throw new NetworkError(err instanceof Error ? err.message : "fetch failed");
  }
  if (!response.ok) {
    await translateError(response);
  }
  if (response.status === 204) return undefined as T;
  return (await parseJson(response)) as T;
};

export const ApiClient = {
  get: <T>(path: string, query?: RequestOptions["query"]) =>
    request<T>("GET", path, { query }),
  post: <T>(path: string, body?: unknown) => request<T>("POST", path, { body }),
  put: <T>(path: string, body?: unknown) => request<T>("PUT", path, { body }),
  patch: <T>(path: string, body?: unknown) => request<T>("PATCH", path, { body }),
  delete: <T = void>(path: string) => request<T>("DELETE", path),
  url: (path: string, query?: RequestOptions["query"]) =>
    buildUrl(path) + buildQuery(query),
};
