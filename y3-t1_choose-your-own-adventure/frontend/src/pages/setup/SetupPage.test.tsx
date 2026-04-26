import { fireEvent, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

vi.mock("../../api", () => ({
  stories: { create: vi.fn(), saveGraph: vi.fn() },
  generation: { generateInitial: vi.fn() },
  auth: {},
  apiKey: {},
}));

import { renderWithProviders } from "../../../tests/test-utils";
import SetupPage from "./SetupPage";

describe("SetupPage", () => {
  it("renders the genre input and the attribute table", () => {
    renderWithProviders(<SetupPage />);
    expect(screen.getByText(/Start a new story/i)).toBeInTheDocument();
    expect(screen.getByText(/Attributes/i)).toBeInTheDocument();
  });

  it("submit button is disabled when genre is empty", () => {
    renderWithProviders(<SetupPage />);
    const button = screen.getByRole("button", { name: /Generate story/i });
    expect(button).toBeDisabled();
  });
});
