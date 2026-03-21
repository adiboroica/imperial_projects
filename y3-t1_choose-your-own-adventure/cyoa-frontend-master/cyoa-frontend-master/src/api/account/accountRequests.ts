import { API_KEY_URL, LOGIN_URL, LOGOUT_URL, SIGNUP_URL, STORIES_URL } from "../links";


export const reqSignup = async (email: string, password: string) => {
	return fetch(SIGNUP_URL, {
		method: "POST",
		body: JSON.stringify({
			email,
			password
		}),
		headers: {
			"Content-Type": "application/json",
		},
		// Required to set session cookie on signup
		credentials: "include",
	});
};

export const reqLogout = async () => {
	return fetch(LOGOUT_URL, {
		method: "GET",
		headers: {
			"Content-Type": "application/json",
		},
		credentials: "include",
	});
};


export const reqLogin = async (email: string, password: string) => {
	return fetch(LOGIN_URL, {
		method: "POST",
		body: JSON.stringify({
			email,
			password
		}),
		headers: {
			"Content-Type": "application/json",
		},
		credentials: "include",
	});
};


export const reqLoginWithSession = async () => {
	return fetch(LOGIN_URL, {
		method: "GET",
		credentials: "include",
	});
};


export const reqGetStories = async () => {
	return fetch(STORIES_URL, {
		method: "POST",
		body: JSON.stringify({
			type: "getStories"
		}),
		credentials: "include",
	});
};


export const reqGetApiKey = async () => {
	return fetch(API_KEY_URL, {
		method: "GET",
		headers: {
			"Content-Type": "application/json",
		},
		credentials: "include",
	});
}


export const reqUpdateApiKey = async (apiKey: string | undefined) => {
	return fetch(API_KEY_URL, {
		method: "POST",
		body: JSON.stringify({
			apiKey
		}),
		headers: {
			"Content-Type": "application/json",
		},
		credentials: "include",
	});
}