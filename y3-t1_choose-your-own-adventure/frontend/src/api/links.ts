export const API_URL: string = import.meta.env.VITE_API_URL || "/api/";
export const WS_URL: string = import.meta.env.VITE_WS_URL ||
  `${window.location.protocol === "https:" ? "wss:" : "ws:"}//${window.location.host}/ws`;

export const LOGIN_URL: string = API_URL + "login";
export const LOGOUT_URL: string = API_URL + "logout";
export const SIGNUP_URL: string = API_URL + "signup";

export const API_KEY_URL: string = API_URL + "key";
export const STORIES_URL: string = API_URL + "stories";
