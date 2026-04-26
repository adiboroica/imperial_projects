/**
 * Auth feature slice — shared state for login, signup, and the account page.
 *
 * Owns `loggedIn`, `user`, `apiKey`, plus the auth + API-key thunks. Pages
 * dispatch these thunks; reducers update state on fulfilment.
 */

import { createAsyncThunk, createSlice, type PayloadAction } from "@reduxjs/toolkit";

import type { User } from "../../../types";
import { apiKey as apiKeyClient, auth as authClient } from "../../../api";
import { WSClient } from "../../../api/clients/ws";

export type AuthState = {
  loggedIn: boolean;
  user: User | null;
  apiKey: string | null;
  /** True between session() dispatch and the first response, used by the route guard. */
  bootstrapping: boolean;
  /** True after a session() rejection so the guard knows to fall back to /login. */
  sessionFailed: boolean;
  error: string | null;
};

const initialState: AuthState = {
  loggedIn: false,
  user: null,
  apiKey: null,
  bootstrapping: true,
  sessionFailed: false,
  error: null,
};

// ---------- Thunks ----------

export const login = createAsyncThunk(
  "auth/login",
  async (body: { email: string; password: string }, { rejectWithValue }) => {
    try {
      return await authClient.login(body);
    } catch (err) {
      return rejectWithValue(errorName(err));
    }
  },
);

export const signup = createAsyncThunk(
  "auth/signup",
  async (body: { email: string; password: string }, { rejectWithValue }) => {
    try {
      return await authClient.signup(body);
    } catch (err) {
      return rejectWithValue(errorName(err));
    }
  },
);

export const logout = createAsyncThunk("auth/logout", async () => {
  // Close the WS first — the server tears down the session record on
  // `authClient.logout()`, after which any subsequent frame on a still-open
  // socket would be rejected with 4001 anyway.
  WSClient.close();
  await authClient.logout();
});

export const session = createAsyncThunk(
  "auth/session",
  async (_, { rejectWithValue }) => {
    try {
      return await authClient.session();
    } catch (err) {
      return rejectWithValue(errorName(err));
    }
  },
);

export const getApiKey = createAsyncThunk(
  "auth/getApiKey",
  async (_, { rejectWithValue }) => {
    try {
      return await apiKeyClient.get();
    } catch (err) {
      return rejectWithValue(errorName(err));
    }
  },
);

export const updateApiKey = createAsyncThunk(
  "auth/updateApiKey",
  async (newKey: string, { rejectWithValue }) => {
    try {
      return await apiKeyClient.put(newKey);
    } catch (err) {
      return rejectWithValue(errorName(err));
    }
  },
);

// ---------- Slice ----------

const slice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    clearAuthError(state) {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(login.fulfilled, (state, action) => {
        state.loggedIn = true;
        state.user = action.payload;
        state.error = null;
      })
      .addCase(login.rejected, (state, action) => {
        state.error = (action.payload as string) ?? "Login failed";
      })
      .addCase(signup.fulfilled, (state, action) => {
        state.loggedIn = true;
        state.user = action.payload;
        state.error = null;
      })
      .addCase(signup.rejected, (state, action) => {
        state.error = (action.payload as string) ?? "Signup failed";
      })
      .addCase(logout.fulfilled, (state) => {
        state.loggedIn = false;
        state.user = null;
        state.apiKey = null;
        state.error = null;
      })
      .addCase(session.fulfilled, (state, action) => {
        state.loggedIn = true;
        state.user = action.payload;
        state.bootstrapping = false;
        state.sessionFailed = false;
      })
      .addCase(session.rejected, (state) => {
        state.loggedIn = false;
        state.user = null;
        state.apiKey = null;
        state.bootstrapping = false;
        state.sessionFailed = true;
      })
      .addCase(getApiKey.fulfilled, (state, action: PayloadAction<string | null>) => {
        state.apiKey = action.payload;
      })
      .addCase(updateApiKey.fulfilled, (state, action: PayloadAction<string | null>) => {
        state.apiKey = action.payload;
        state.error = null;
      })
      .addCase(updateApiKey.rejected, (state, action) => {
        state.error = (action.payload as string) ?? "Failed to update API key";
      });
  },
});

const errorName = (err: unknown): string =>
  err instanceof Error ? err.name : "Error";

export const { clearAuthError } = slice.actions;
export default slice.reducer;

// ---------- Selectors ----------

import type { RootState } from "../../../store/store";

export const selectAuthLoggedIn = (s: RootState) => s.auth.loggedIn;
export const selectAuthUser = (s: RootState) => s.auth.user;
export const selectAuthApiKey = (s: RootState) => s.auth.apiKey;
export const selectAuthBootstrapping = (s: RootState) => s.auth.bootstrapping;
export const selectAuthSessionFailed = (s: RootState) => s.auth.sessionFailed;
export const selectAuthError = (s: RootState) => s.auth.error;
