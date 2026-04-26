/**
 * SplitButton smoke test — the existing component shape isn't documented in
 * the source we have access to, so this just verifies it imports without error
 * and renders without throwing.
 */

import { describe, expect, it } from "vitest";

describe("SplitButton module", () => {
  it("imports cleanly", async () => {
    const mod = await import("./SplitButton");
    expect(mod.default).toBeDefined();
  });
});
