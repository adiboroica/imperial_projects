import { describe, expect, it, vi } from "vitest";

// Page-level tests for GeneratorPage are kept lightweight because the
// component depends on ReactFlow (which uses ResizeObserver) and dagre layout
// — both heavy to set up in jsdom. Slice and api tests cover the data layer.

vi.mock("@xyflow/react", () => ({
  ReactFlow: ({ children }: { children: React.ReactNode }) => (
    <div data-testid="reactflow-stub">{children}</div>
  ),
  Background: () => null,
  Controls: () => null,
  Handle: () => null,
  Position: { Top: "top", Bottom: "bottom" },
  useNodesState: (init: unknown) => [init, vi.fn(), vi.fn()],
  useEdgesState: (init: unknown) => [init, vi.fn(), vi.fn()],
}));

vi.mock("../../api", () => ({
  stories: { getById: vi.fn().mockResolvedValue({
    id: "s1",
    name: "S",
    graph: { nodeLookup: {} },
    createdAt: "",
    updatedAt: "",
  }) },
  generation: {},
  auth: {},
  apiKey: {},
}));

describe("GeneratorPage module", () => {
  // Dynamic import pulls in Mantine + ReactFlow + redux toolkit; the cold
  // module graph trip can exceed vitest's 5s default under parallel load.
  it(
    "imports without throwing",
    async () => {
      const mod = await import("./GeneratorPage");
      expect(mod.default).toBeDefined();
    },
    15000,
  );
});
