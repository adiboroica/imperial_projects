/**
 * Architecture purity test.
 *
 * Statement-level rules that aren't expressible as edge contracts. Enforces:
 *   - No `createSlice` or `createAsyncThunk` lives under `store/**` —
 *     slices/thunks must live in pages or features.
 */

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, resolve } from "node:path";

import { describe, it, expect } from "vitest";

const PROJECT_ROOT = resolve(__dirname, "..", "..");
const STORE_ROOT = resolve(PROJECT_ROOT, "src", "store");

const collectTsFiles = (dir: string, into: string[] = []): string[] => {
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    const stat = statSync(full);
    if (stat.isDirectory()) {
      collectTsFiles(full, into);
    } else if (/\.(ts|tsx)$/.test(entry)) {
      into.push(full);
    }
  }
  return into;
};

describe("architecture purity", () => {
  it("store/ defines no slices or thunks", () => {
    const files = collectTsFiles(STORE_ROOT);
    const offenders: string[] = [];
    for (const file of files) {
      const contents = readFileSync(file, "utf-8");
      if (/\bcreateSlice\b/.test(contents) || /\bcreateAsyncThunk\b/.test(contents)) {
        offenders.push(file);
      }
    }
    expect(offenders, `Slices / thunks must live under pages or features, not store/. Offenders:\n${offenders.join("\n")}`).toEqual([]);
  });
});
