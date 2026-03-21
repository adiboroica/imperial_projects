import { graphToGraphMessage } from "../../utils/graph/graphUtils";
import { Graph } from "../../utils/graph/types";
import { STORIES_URL } from "../links";


export const reqGetStory = async (storyId: string) => {
	return fetch(STORIES_URL, {
		method: "POST",
		body: JSON.stringify({
			type: "getStoryFromId",
			storyId
		}),
		credentials: "include",
	});
};


export const reqInitStory = async () => {
	return fetch(STORIES_URL, {
		method: "POST",
		body: JSON.stringify({
			type: "init"
		}),
		credentials: "include",
	});
};


export const reqSaveName = async (storyId: string, name: string) => {
	return fetch(STORIES_URL, {
		method: "POST",
		body: JSON.stringify({
			type: "saveName",
			storyId,
			name
		}),
		credentials: "include",
	});
};


export const reqSaveGraph = async (storyId: string, graph: Graph) => {
	return fetch(STORIES_URL, {
		method: "POST",
		body: JSON.stringify({
			type: "saveStory",
			storyId,
			story: graphToGraphMessage(graph),
		}),
		credentials: "include",
	});
};


export const reqDeleteStory = async (storyId: string) => {
	return fetch(STORIES_URL, {
		method: "POST",
		body: JSON.stringify({
			type: "deleteStoryFromId",
			storyId
		}),
		credentials: "include",
	});
};
