import { fireEvent, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import { renderWithProviders } from "../../../../../tests/test-utils";
import GraphContextMenu from "./GraphContextMenu";

const POS = { x: 120, y: 80 };

describe("GraphContextMenu", () => {
  it("renders nothing when position is null", () => {
    const { container } = renderWithProviders(
      <GraphContextMenu position={null} onClose={vi.fn()} />,
    );
    // Mantine Menu still mounts a portal root in the DOM, but no menu item text leaks.
    expect(container.querySelector('[style*="position: fixed"]')).toBeNull();
  });

  it("renders only the items whose callbacks are supplied", () => {
    renderWithProviders(
      <GraphContextMenu
        position={POS}
        onClose={vi.fn()}
        onDelete={vi.fn()}
        onExpand={vi.fn()}
      />,
    );
    expect(screen.getByText("Expand")).toBeInTheDocument();
    expect(screen.getByText("Delete")).toBeInTheDocument();
    expect(screen.queryByText("Disconnect")).toBeNull();
  });

  it("fires the matching callback and onClose when an item is clicked", () => {
    const onDelete = vi.fn();
    const onClose = vi.fn();
    renderWithProviders(
      <GraphContextMenu
        position={POS}
        onClose={onClose}
        onDelete={onDelete}
      />,
    );
    fireEvent.click(screen.getByText("Delete"));
    expect(onDelete).toHaveBeenCalledTimes(1);
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("fires onClose when the user clicks outside the menu", () => {
    const onClose = vi.fn();
    renderWithProviders(
      <GraphContextMenu
        position={POS}
        onClose={onClose}
        onDelete={vi.fn()}
      />,
    );
    fireEvent.mouseDown(document.body);
    expect(onClose).toHaveBeenCalledTimes(1);
  });
});
