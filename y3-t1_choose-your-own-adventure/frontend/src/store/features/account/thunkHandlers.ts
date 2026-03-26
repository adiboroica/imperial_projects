import { PayloadAction } from "@reduxjs/toolkit";
import StatusCode from "status-code-enum";
import { AccountState } from "../accountSlice";
import { AuthResponse, StoryListEntry } from "./types";


export const handleLoginFulfilled = (
  state: AccountState,
  action: PayloadAction<AuthResponse>,
) => {
  const status = action.payload.status;
  if (status !== StatusCode.SuccessOK) {
    handleLoginRejected(state);
    return;
  }

  state.loggedIn = true;
  state.credentialsLoginFail = false;

  state.email = action.payload.email;
};
export const handleLoginRejected = (state: AccountState) => {
  state.credentialsLoginFail = true;
};


export const handleLoginWithSessionFulfilled = (
  state: AccountState,
  action: PayloadAction<AuthResponse>,
) => {
  const status = action.payload.status;
  if (status !== StatusCode.SuccessOK) {
    handleLoginWithSessionRejected(state);
    return;
  }

  state.loggedIn = true;
  state.sessionLoginFail = false;

  state.email = action.payload.email;
};
export const handleLoginWithSessionRejected = (state: AccountState) => {
  state.sessionLoginFail = true;
};


export const handleSignupFulfilled = (
  state: AccountState,
  action: PayloadAction<AuthResponse>,
) => {
  const status = action.payload.status;
  if (status === StatusCode.ClientErrorUnauthorized) {
    state.signupError = true;
    return;
  }

  state.loggedIn = true;
  state.sessionLoginFail = false;
  state.credentialsLoginFail = false;

  state.email = action.payload.email;
};
export const handleSignupRejected = (
  state: AccountState,
) => {
    state.signupError = true;
};


export const handleLoadStoriesFulfilled = (
  state: AccountState,
  action: PayloadAction<StoryListEntry[]>
) => {
  state.stories = action.payload;
};


export const handleGetApiKeyFulfilled = (
  state: AccountState,
  action: PayloadAction<string>
) => {
  state.apiKey = action.payload;
};


export const handleUpdateApiKeyFulfilled = (
  state: AccountState,
  action: PayloadAction<string>
) => {
  state.apiKey = action.payload;
};


export const handleDeleteStoryFulfilled = (
  state: AccountState,
  action: PayloadAction<string>
) => {
  state.stories = state.stories?.filter((story) => story.storyId !== action.payload);
};

export const handleLogoutComplete = (
  state: AccountState
) => {
  state.loggedIn = false;
};
