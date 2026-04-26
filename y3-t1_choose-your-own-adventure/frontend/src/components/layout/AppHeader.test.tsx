import { screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import { renderWithProviders } from "../../../tests/test-utils";
import AppHeader from "./AppHeader";

describe("AppHeader", () => {
  it("renders the supplied tab links", () => {
    renderWithProviders(
      <AppHeader
        loggedIn={false}
        onLogout={vi.fn()}
        links={[
          { label: "Home", link: "/" },
          { label: "Dashboard", link: "/dashboard" },
        ]}
      />,
    );
    expect(screen.getByText("Home")).toBeInTheDocument();
    expect(screen.getByText("Dashboard")).toBeInTheDocument();
  });

  it("renders an Account dropdown affordance", () => {
    renderWithProviders(
      <AppHeader loggedIn={true} onLogout={vi.fn()} links={[]} />,
    );
    expect(screen.getByText("Account")).toBeInTheDocument();
  });
});
