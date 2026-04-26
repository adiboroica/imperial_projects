import { fireEvent, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import { renderWithProviders } from "../../../../tests/test-utils";
import GenreHandler from "./GenreHandler";

describe("GenreHandler", () => {
  it("renders the dropdown when value is empty (preset mode)", () => {
    renderWithProviders(<GenreHandler value="" onChange={vi.fn()} />);
    expect(screen.getByLabelText("Custom")).not.toBeChecked();
    // Custom mode renders a single TextInput; preset mode renders the
    // dropdown wrapper instead. Absence of the placeholder text confirms it.
    expect(screen.queryByPlaceholderText("custom genre")).toBeNull();
  });

  it("starts in custom mode when the supplied value is not a known genre", () => {
    renderWithProviders(
      <GenreHandler value="cyberpunk-noir" onChange={vi.fn()} />,
    );
    expect(screen.getByLabelText("Custom")).toBeChecked();
    expect(screen.getByPlaceholderText("custom genre")).toHaveValue(
      "cyberpunk-noir",
    );
  });

  it("toggling Custom on swaps to a free-text input", () => {
    renderWithProviders(<GenreHandler value="" onChange={vi.fn()} />);
    fireEvent.click(screen.getByLabelText("Custom"));
    expect(screen.getByPlaceholderText("custom genre")).toBeInTheDocument();
  });

  it("toggling Custom off clears the value via onChange", () => {
    const onChange = vi.fn();
    renderWithProviders(
      <GenreHandler value="cyberpunk-noir" onChange={onChange} />,
    );
    fireEvent.click(screen.getByLabelText("Custom"));
    expect(onChange).toHaveBeenCalledWith("");
  });

  it("editing the custom-mode TextInput propagates via onChange", () => {
    const onChange = vi.fn();
    renderWithProviders(<GenreHandler value="anything" onChange={onChange} />);
    fireEvent.change(screen.getByPlaceholderText("custom genre"), {
      target: { value: "steampunk" },
    });
    expect(onChange).toHaveBeenLastCalledWith("steampunk");
  });
});
