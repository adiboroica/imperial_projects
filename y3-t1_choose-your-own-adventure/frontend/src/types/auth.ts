/**
 * Auth request shapes for the `/auth/*` routes.
 */

export type LoginRequest = {
  email: string;
  password: string;
};

export type SignupRequest = {
  email: string;
  password: string;
};
