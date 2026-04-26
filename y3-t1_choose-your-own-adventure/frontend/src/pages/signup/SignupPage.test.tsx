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
import SignupPage from "./SignupPage";

describe("SignupPage", () => {
  it("renders email + password fields with min length hint", () => {
    renderWithProviders(<SignupPage />);
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByText(/Minimum 8 characters/i)).toBeInTheDocument();
  });

  it("dispatches signup on submit", async () => {
    (auth.signup as any).mockResolvedValueOnce({ email: "a@b.com" });
    renderWithProviders(<SignupPage />);
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: "a@b.com" },
    });
    fireEvent.change(screen.getByLabelText(/password/i), {
      target: { value: "longenough" },
    });
    fireEvent.click(screen.getByRole("button", { name: /sign up/i }));
    await waitFor(() => expect(auth.signup).toHaveBeenCalled());
  });
});
