/**
 * Auth domain wrappers — `/auth/*` REST surface.
 */

import type { LoginRequest, SignupRequest, User } from "../types";
import { ApiClient } from "./clients/http";
import {
  Conflict,
  EmailAlreadyExists,
  InvalidCredentials,
  Unauthenticated,
} from "./errors";

export const auth = {
  /** `POST /auth/login` — narrows 401 → `InvalidCredentials`. */
  login: async (body: LoginRequest): Promise<User> => {
    try {
      return await ApiClient.post<User>("/auth/login", body);
    } catch (err) {
      if (err instanceof Unauthenticated) throw new InvalidCredentials();
      throw err;
    }
  },

  /** `POST /auth/signup` — narrows 409 → `EmailAlreadyExists`. */
  signup: async (body: SignupRequest): Promise<User> => {
    try {
      return await ApiClient.post<User>("/auth/signup", body);
    } catch (err) {
      if (err instanceof Conflict) throw new EmailAlreadyExists();
      throw err;
    }
  },

  /** `POST /auth/logout` — never throws on missing session. */
  logout: async (): Promise<void> => {
    await ApiClient.post<void>("/auth/logout");
  },

  /**
   * `GET /auth/session` — returns the current `User`; throws `Unauthenticated`
   * when no session is active. Called once at app boot to restore.
   */
  session: async (): Promise<User> => {
    return await ApiClient.get<User>("/auth/session");
  },
};
