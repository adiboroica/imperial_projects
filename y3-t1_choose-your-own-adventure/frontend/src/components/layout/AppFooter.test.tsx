import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import { renderWithProviders } from "../../../tests/test-utils";
import AppFooter from "./AppFooter";

describe("AppFooter", () => {
  it("renders the project name", () => {
    renderWithProviders(<AppFooter />);
    expect(screen.getByText(/CYOA/i)).toBeInTheDocument();
  });
});
