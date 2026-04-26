import { describe, expect, it, vi } from "vitest";

import { auth } from "./auth";
import {
  Conflict,
  EmailAlreadyExists,
  InvalidCredentials,
  Unauthenticated,
} from "./errors";

vi.mock("./clients/http", () => ({
  ApiClient: {
    get: vi.fn(),
    post: vi.fn(),
    put: vi.fn(),
    patch: vi.fn(),
    delete: vi.fn(),
    url: vi.fn(),
  },
}));

import { ApiClient } from "./clients/http";

describe("api.auth", () => {
  it("login returns User on success", async () => {
    (ApiClient.post as any).mockResolvedValueOnce({ email: "a@b.com" });
    const u = await auth.login({ email: "a@b.com", password: "x" });
    expect(u.email).toBe("a@b.com");
  });

  it("login narrows 401 to InvalidCredentials", async () => {
    (ApiClient.post as any).mockRejectedValueOnce(new Unauthenticated());
    await expect(
      auth.login({ email: "a@b.com", password: "x" }),
    ).rejects.toBeInstanceOf(InvalidCredentials);
  });

  it("signup narrows 409 to EmailAlreadyExists", async () => {
    (ApiClient.post as any).mockRejectedValueOnce(new Conflict());
    await expect(
      auth.signup({ email: "a@b.com", password: "longenough" }),
    ).rejects.toBeInstanceOf(EmailAlreadyExists);
  });

  it("session throws Unauthenticated when not signed in", async () => {
    (ApiClient.get as any).mockRejectedValueOnce(new Unauthenticated());
    await expect(auth.session()).rejects.toBeInstanceOf(Unauthenticated);
  });
});
