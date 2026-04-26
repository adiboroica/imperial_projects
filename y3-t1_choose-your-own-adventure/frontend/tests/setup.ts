/**
 * Vitest setup file — runs before every test.
 *
 * Imports `@testing-library/jest-dom` matchers (toBeInTheDocument, etc.)
 * and stubs the `fetch`, `WebSocket`, and `ResizeObserver` globals so a stray
 * production-pointing call fails fast rather than silently hitting localhost.
 */

import "@testing-library/jest-dom/vitest";
import { afterEach, vi } from "vitest";
import { cleanup } from "@testing-library/react";

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

// Default `fetch` stub — tests that need real responses override per-test.
if (typeof globalThis.fetch === "undefined" || !vi.isMockFunction(globalThis.fetch)) {
  vi.stubGlobal(
    "fetch",
    vi.fn(() =>
      Promise.reject(new Error("fetch not mocked — provide a mock in your test")),
    ),
  );
}

/**
 * Mock WebSocket that records every instance on `globalThis.__wsInstances`
 * so tests can deterministically `triggerOpen` / `triggerClose` from the outside.
 */
export class MockWebSocket {
  static CONNECTING = 0;
  static OPEN = 1;
  static CLOSING = 2;
  static CLOSED = 3;
  readyState = 0;
  onopen: ((ev: Event) => void) | null = null;
  onmessage: ((ev: MessageEvent) => void) | null = null;
  onclose: ((ev: CloseEvent) => void) | null = null;
  onerror: ((ev: Event) => void) | null = null;
  send = vi.fn();
  close = vi.fn((code?: number) => {
    this.readyState = MockWebSocket.CLOSED;
    if (this.onclose) {
      this.onclose(new CloseEvent("close", { code: code ?? 1000 }));
    }
  });
  constructor(public url: string) {
    const instances =
      (globalThis as unknown as { __wsInstances?: MockWebSocket[] })
        .__wsInstances ?? [];
    instances.push(this);
    (globalThis as unknown as { __wsInstances: MockWebSocket[] }).__wsInstances =
      instances;
  }
  triggerOpen() {
    this.readyState = MockWebSocket.OPEN;
    if (this.onopen) this.onopen(new Event("open"));
  }
  triggerMessage(data: string) {
    if (this.onmessage) this.onmessage(new MessageEvent("message", { data }));
  }
  triggerClose(code: number = 1006) {
    this.readyState = MockWebSocket.CLOSED;
    if (this.onclose) this.onclose(new CloseEvent("close", { code }));
  }
}
vi.stubGlobal("WebSocket", MockWebSocket);

/**
 * `ResizeObserver` polyfill — required by ReactFlow when running under jsdom.
 */
class MockResizeObserver {
  observe = vi.fn();
  unobserve = vi.fn();
  disconnect = vi.fn();
}
vi.stubGlobal("ResizeObserver", MockResizeObserver);

/**
 * `window.matchMedia` polyfill — Mantine's `MantineProvider` and `useMediaQuery`
 * hook both read this. jsdom does not implement it. We register on both
 * `window` and `globalThis` so every call site finds it.
 */
const matchMediaMock = (query: string): MediaQueryList => {
  const list: Partial<MediaQueryList> & { matches: boolean; media: string } = {
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(() => false),
  };
  return list as MediaQueryList;
};

// Register on both `window` and `globalThis`. We use a plain function
// (not a `vi.fn()`) because `vi.restoreAllMocks()` in `afterEach` would
// otherwise strip the implementation and leave subsequent tests staring at
// `undefined.matches`.
if (typeof window !== "undefined" && typeof window.matchMedia !== "function") {
  Object.defineProperty(window, "matchMedia", {
    writable: true,
    configurable: true,
    value: matchMediaMock,
  });
}
if (typeof globalThis.matchMedia !== "function") {
  Object.defineProperty(globalThis, "matchMedia", {
    writable: true,
    configurable: true,
    value: matchMediaMock,
  });
}

/**
 * `DOMMatrix` polyfill — also used by some xyflow internals.
 */
if (typeof globalThis.DOMMatrix === "undefined") {
  vi.stubGlobal(
    "DOMMatrix",
    class {
      m11 = 1;
      m22 = 1;
      m41 = 0;
      m42 = 0;
    },
  );
}

beforeEach(() => {
  // Reset the captured-instances list each test.
  (globalThis as unknown as { __wsInstances: MockWebSocket[] }).__wsInstances =
    [];
});

// vitest's `beforeEach` is auto-imported via `globals: true`.
declare const beforeEach: (fn: () => void) => void;
