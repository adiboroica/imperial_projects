import { screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

vi.mock("../../api", () => ({
  auth: { logout: vi.fn() },
  apiKey: { get: vi.fn().mockResolvedValue(null), put: vi.fn() },
  stories: {},
  generation: {},
}));

import { renderWithProviders } from "../../../tests/test-utils";
import AccountPage from "./AccountPage";

describe("AccountPage", () => {
  it("shows the logged-in user's email and a logout button", async () => {
    const preloaded: any = {
      auth: {
        loggedIn: true,
        user: { email: "a@b.com" },
        apiKey: null,
        bootstrapping: false,
        sessionFailed: false,
        error: null,
      },
    };
    renderWithProviders(<AccountPage />, { preloadedState: preloaded });
    expect(await screen.findByText("a@b.com")).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: /log out/i }),
    ).toBeInTheDocument();
  });
});
