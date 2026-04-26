import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import { renderWithProviders } from "../../../tests/test-utils";
import WelcomePage from "./WelcomePage";

describe("WelcomePage", () => {
  it("renders the hero title", () => {
    renderWithProviders(<WelcomePage />);
    expect(
      screen.getByRole("heading", { name: /choose your own adventure/i }),
    ).toBeInTheDocument();
  });

  it("links to /login and /signup", () => {
    renderWithProviders(<WelcomePage />);
    expect(screen.getByRole("link", { name: /log in/i })).toHaveAttribute(
      "href",
      "/login",
    );
    expect(screen.getByRole("link", { name: /sign up/i })).toHaveAttribute(
      "href",
      "/signup",
    );
  });
});
