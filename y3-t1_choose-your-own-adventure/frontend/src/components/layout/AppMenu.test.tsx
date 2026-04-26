import { fireEvent, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import { renderWithProviders } from "../../../tests/test-utils";
import AppMenu from "./AppMenu";

describe("AppMenu", () => {
  it("renders the Account trigger", () => {
    renderWithProviders(<AppMenu loggedIn={false} onLogout={vi.fn()} />);
    expect(screen.getByText("Account")).toBeInTheDocument();
  });

  it("opens the dropdown and shows a Log in item when logged out", async () => {
    renderWithProviders(<AppMenu loggedIn={false} onLogout={vi.fn()} />);
    fireEvent.click(screen.getByText("Account"));
    // Mantine Menu opens via a transition; the items appear asynchronously
    // in the portal, so use findByText to retry until the dropdown mounts.
    expect(await screen.findByText("Account settings")).toBeInTheDocument();
    expect(await screen.findByText("Log in")).toBeInTheDocument();
    expect(screen.queryByText("Log out")).toBeNull();
  });

  it("opens the dropdown and shows a Log out item when logged in", async () => {
    renderWithProviders(<AppMenu loggedIn={true} onLogout={vi.fn()} />);
    fireEvent.click(screen.getByText("Account"));
    expect(await screen.findByText("Log out")).toBeInTheDocument();
    expect(screen.queryByText("Log in")).toBeNull();
  });

  it("fires onLogout when the Log out item is clicked", async () => {
    const onLogout = vi.fn();
    renderWithProviders(<AppMenu loggedIn={true} onLogout={onLogout} />);
    fireEvent.click(screen.getByText("Account"));
    fireEvent.click(await screen.findByText("Log out"));
    expect(onLogout).toHaveBeenCalledTimes(1);
  });
});
