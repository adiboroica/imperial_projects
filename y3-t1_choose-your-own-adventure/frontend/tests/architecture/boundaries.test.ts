/**
 * Architecture boundaries test.
 *
 * Subprocess `dependency-cruiser` against the project's `.dependency-cruiser.cjs`
 * and fail the test if any contract is violated.
 */

import { execSync } from "node:child_process";
import { existsSync } from "node:fs";
import { resolve } from "node:path";

import { describe, it } from "vitest";

const PROJECT_ROOT = resolve(__dirname, "..", "..");

describe("architecture boundaries", () => {
  it("dependency-cruiser contracts pass", () => {
    const configPath = resolve(__dirname, ".dependency-cruiser.cjs");
    if (!existsSync(configPath)) {
      throw new Error(`Missing config at ${configPath}`);
    }
    try {
      execSync(`npx --yes depcruise --config "${configPath}" src`, {
        cwd: PROJECT_ROOT,
        stdio: "pipe",
      });
    } catch (err) {
      const e = err as { stdout?: Buffer; stderr?: Buffer };
      const stdout = e.stdout?.toString() ?? "";
      const stderr = e.stderr?.toString() ?? "";
      throw new Error(
        `dependency-cruiser violations:\n--- stdout ---\n${stdout}\n--- stderr ---\n${stderr}`,
      );
    }
  });
});
