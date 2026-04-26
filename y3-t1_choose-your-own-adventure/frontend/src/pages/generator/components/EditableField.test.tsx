import { fireEvent, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import { renderWithProviders } from "../../../../tests/test-utils";
import EditableField from "./EditableField";

describe("EditableField", () => {
  it("renders the value as static text by default", () => {
    renderWithProviders(<EditableField value="hello" />);
    expect(screen.getByText("hello")).toBeInTheDocument();
  });

  it("clicking the edit icon swaps to a textarea", () => {
    renderWithProviders(<EditableField value="hello" />);
    fireEvent.click(screen.getByRole("button"));
    expect(screen.getByRole("textbox")).toHaveValue("hello");
  });

  it("commits the new value via onCommit", () => {
    const onCommit = vi.fn();
    renderWithProviders(<EditableField value="hello" onCommit={onCommit} />);
    fireEvent.click(screen.getByRole("button")); // enter edit mode
    const ta = screen.getByRole("textbox");
    fireEvent.change(ta, { target: { value: "updated" } });
    // The "done" button is the second action icon now.
    const buttons = screen.getAllByRole("button");
    fireEvent.click(buttons[buttons.length - 1]);
    expect(onCommit).toHaveBeenCalledWith("updated");
  });

  it("disabled prop disables the edit affordance", () => {
    renderWithProviders(<EditableField value="hello" disabled />);
    const button = screen.getByRole("button");
    expect(button).toBeDisabled();
  });
});
