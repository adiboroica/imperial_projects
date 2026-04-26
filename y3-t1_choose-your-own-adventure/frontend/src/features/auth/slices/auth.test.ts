/**
 * Auth feature slice tests.
 *
 * Mocks the api modules at the import level so thunks resolve without a network call.
 */

import { configureStore } from "@reduxjs/toolkit";
import { describe, expect, it, vi } from "vitest";

import authReducer, {
  getApiKey,
  login,
  logout,
  selectAuthApiKey,
  selectAuthLoggedIn,
  selectAuthSessionFailed,
  selectAuthUser,
  session,
  signup,
  updateApiKey,
} from "./auth";

vi.mock("../../../api", () => ({
  auth: {
    login: vi.fn(),
    signup: vi.fn(),
    logout: vi.fn(),
    session: vi.fn(),
  },
  apiKey: {
    get: vi.fn(),
    put: vi.fn(),
  },
}));

import { auth as authClient, apiKey as apiKeyClient } from "../../../api";

const makeStore = () =>
  configureStore({ reducer: { auth: authReducer } });

describe("auth slice", () => {
  it("login.fulfilled sets loggedIn and user", async () => {
    const store = makeStore();
    (authClient.login as any).mockResolvedValueOnce({ email: "a@b.com" });
    await store.dispatch(login({ email: "a@b.com", password: "x" }));
    const state: any = store.getState();
    expect(selectAuthLoggedIn(state)).toBe(true);
    expect(selectAuthUser(state)?.email).toBe("a@b.com");
  });

  it("signup.fulfilled sets loggedIn and user", async () => {
    const store = makeStore();
    (authClient.signup as any).mockResolvedValueOnce({ email: "a@b.com" });
    await store.dispatch(signup({ email: "a@b.com", password: "longenough" }));
    const state: any = store.getState();
    expect(selectAuthLoggedIn(state)).toBe(true);
  });

  it("logout.fulfilled clears state", async () => {
    const store = makeStore();
    (authClient.login as any).mockResolvedValueOnce({ email: "a@b.com" });
    await store.dispatch(login({ email: "a@b.com", password: "x" }));
    (authClient.logout as any).mockResolvedValueOnce(undefined);
    await store.dispatch(logout());
    const state: any = store.getState();
    expect(selectAuthLoggedIn(state)).toBe(false);
    expect(selectAuthUser(state)).toBeNull();
  });

  it("getApiKey.fulfilled populates apiKey", async () => {
    const store = makeStore();
    (apiKeyClient.get as any).mockResolvedValueOnce("sk-test");
    await store.dispatch(getApiKey());
    expect(selectAuthApiKey(store.getState() as any)).toBe("sk-test");
  });

  it("updateApiKey.fulfilled updates apiKey", async () => {
    const store = makeStore();
    (apiKeyClient.put as any).mockResolvedValueOnce("sk-new");
    await store.dispatch(updateApiKey("sk-new"));
    expect(selectAuthApiKey(store.getState() as any)).toBe("sk-new");
  });

  it("session.rejected clears state and marks sessionFailed", async () => {
    const store = makeStore();
    (authClient.session as any).mockRejectedValueOnce(new Error("nope"));
    await store.dispatch(session());
    const state: any = store.getState();
    expect(selectAuthLoggedIn(state)).toBe(false);
    expect(selectAuthSessionFailed(state)).toBe(true);
  });

  it("login.rejected populates error", async () => {
    const store = makeStore();
    (authClient.login as any).mockRejectedValueOnce(
      Object.assign(new Error("bad"), { name: "InvalidCredentials" }),
    );
    await store.dispatch(login({ email: "a@b.com", password: "x" }));
    const state: any = store.getState();
    expect(state.auth.error).toBeTruthy();
  });
});
