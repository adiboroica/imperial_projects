/**
 * User types — mirror the backend's `models/auth.UserResponse`.
 *
 * Internal fields (`passwordHash`, `apiKey`) never appear on the wire; this
 * type matches what `/auth/session` and friends actually return.
 */

export type User = {
  email: string;
};
