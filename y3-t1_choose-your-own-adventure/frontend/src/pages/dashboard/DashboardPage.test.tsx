import { screen, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

vi.mock("../../api", () => ({
  stories: {
    list: vi.fn().mockResolvedValue([
      { id: "s1", name: "Crystal Caverns", firstParagraph: "...", totalSections: 3 },
    ]),
    delete: vi.fn(),
  },
  auth: {},
  apiKey: {},
  generation: {},
}));

import { renderWithProviders } from "../../../tests/test-utils";
import DashboardPage from "./DashboardPage";

describe("DashboardPage", () => {
  it("fetches stories on mount and renders the list", async () => {
    renderWithProviders(<DashboardPage />);
    await waitFor(() =>
      expect(screen.getByText("Crystal Caverns")).toBeInTheDocument(),
    );
  });

  it("renders an empty state when the list is empty", async () => {
    const { stories } = await import("../../api");
    (stories.list as any).mockResolvedValueOnce([]);
    renderWithProviders(<DashboardPage />);
    await waitFor(() => {
      expect(screen.getByText(/No stories yet/i)).toBeInTheDocument();
    });
  });
});
