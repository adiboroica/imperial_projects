import { fireEvent, screen, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

vi.mock("../../api", () => ({
  auth: {
    login: vi.fn(),
    signup: vi.fn(),
    logout: vi.fn(),
    session: vi.fn(),
  },
  apiKey: { get: vi.fn(), put: vi.fn() },
  stories: {},
  generation: {},
}));

import { renderWithProviders } from "../../../tests/test-utils";
import { auth } from "../../api";
import LoginPage from "./LoginPage";

describe("LoginPage", () => {
  it("renders email and password inputs", () => {
    renderWithProviders(<LoginPage />);
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
  });

  it("dispatches login on submit", async () => {
    (auth.login as any).mockResolvedValueOnce({ email: "a@b.com" });
    renderWithProviders(<LoginPage />);
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: "a@b.com" },
    });
    fireEvent.change(screen.getByLabelText(/password/i), {
      target: { value: "password" },
    });
    fireEvent.click(screen.getByRole("button", { name: /log in/i }));
    await waitFor(() => expect(auth.login).toHaveBeenCalled());
  });
});
