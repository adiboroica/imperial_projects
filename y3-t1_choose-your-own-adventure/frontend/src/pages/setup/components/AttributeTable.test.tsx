import { fireEvent, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import { renderWithProviders } from "../../../../tests/test-utils";
import AttributeTable from "./AttributeTable";

const rows = [
  { attribute: "themes", content: "" },
  { attribute: "characters", content: "" },
];

const baseProps = {
  rows,
  onAttribute: vi.fn(),
  onContent: vi.fn(),
  onAdd: vi.fn(),
  onRemove: vi.fn(),
};

describe("AttributeTable", () => {
  it("renders one input row per attribute plus an Add button", () => {
    renderWithProviders(<AttributeTable {...baseProps} />);
    expect(screen.getByText("Attributes")).toBeInTheDocument();
    // Each `InputTextForm` row is a pair of TextInputs labelled
    // "Attribute" and "Content"; one row → one of each.
    expect(screen.getAllByLabelText("Attribute").length).toBe(rows.length);
    expect(screen.getAllByLabelText("Content").length).toBe(rows.length);
    expect(screen.getByRole("button", { name: /add attribute/i })).toBeEnabled();
  });

  it("fires onAdd when the Add attribute button is clicked", () => {
    const onAdd = vi.fn();
    renderWithProviders(<AttributeTable {...baseProps} onAdd={onAdd} />);
    fireEvent.click(screen.getByRole("button", { name: /add attribute/i }));
    expect(onAdd).toHaveBeenCalledTimes(1);
  });

  it("disables the Add button and rows when disabled prop is true", () => {
    renderWithProviders(<AttributeTable {...baseProps} disabled />);
    expect(screen.getByRole("button", { name: /add attribute/i })).toBeDisabled();
  });

  it("renders an empty rows list without crashing", () => {
    renderWithProviders(<AttributeTable {...baseProps} rows={[]} />);
    expect(screen.getByText("Attributes")).toBeInTheDocument();
    expect(screen.queryAllByLabelText("Attribute").length).toBe(0);
  });
});
