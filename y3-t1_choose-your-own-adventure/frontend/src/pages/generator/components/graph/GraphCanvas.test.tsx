import { describe, expect, it, vi } from "vitest";
import { screen } from "@testing-library/react";

import { renderWithProviders } from "../../../../../tests/test-utils";
import { NodeType } from "../../../../types";

// `@xyflow/react` and the dagre layout helpers depend on browser canvas APIs
// that jsdom does not implement. Mock both so the test can mount the
// component without the real ReactFlow runtime.
vi.mock("@xyflow/react", () => ({
  ReactFlow: ({ nodes }: { nodes: { id: string }[] }) => (
    <div data-testid="reactflow-stub">
      {nodes.map((n) => (
        <div key={n.id} data-testid="rf-node" />
      ))}
    </div>
  ),
  Background: () => null,
  Controls: () => null,
  Handle: () => null,
  Position: { Top: "top", Bottom: "bottom" },
  useNodesState: (init: unknown) => [init, vi.fn(), vi.fn()],
  useEdgesState: (init: unknown) => [init, vi.fn(), vi.fn()],
}));

vi.mock("./graphLayout", () => ({
  dagreLayout: (nodes: unknown) => nodes,
}));

import GraphCanvas from "./GraphCanvas";

describe("GraphCanvas", () => {
  it("renders the empty-graph fallback when the graph has no nodes", () => {
    renderWithProviders(<GraphCanvas />);
    expect(
      screen.getByText(/no content yet/i),
    ).toBeInTheDocument();
    expect(screen.queryByTestId("reactflow-stub")).toBeNull();
  });

  it("renders ReactFlow with one node per Graph entry when populated", () => {
    const preloadedState = {
      graph: {
        storyId: "s1",
        name: "Demo",
        graph: {
          nodeLookup: {
            0: {
              nodeId: 0,
              type: NodeType.Narrative,
              data: "Root",
              childrenIds: [],
              isEnding: false,
            },
          },
        },
        graphLoaded: true,
        activeNodeId: 0,
        numOfEdits: 0,
        loadError: null,
      },
    };
    renderWithProviders(<GraphCanvas />, { preloadedState });
    expect(screen.getByTestId("reactflow-stub")).toBeInTheDocument();
    expect(screen.getAllByTestId("rf-node").length).toBe(1);
  });
});
