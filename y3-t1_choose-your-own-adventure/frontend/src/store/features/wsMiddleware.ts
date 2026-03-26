
import { Middleware } from 'redux';
import { WS_URL } from '../../api/links';
import {
  addActionMsg,
  connectNodesMsg,
  generateActionsMsg, generateInitialStoryMsg, generateManyMsg, generateNarrativeMsg
} from '../../api/story/storyMessages';
import { graphMessageToGraphLookup } from '../../utils/graph/graphUtils';
import { GraphMessage } from '../../utils/graph/types';
import {
  connectNodesWithMiddle,
  generateActions,
  generateNewAction,
  generateEnding, generateInitialStoryAdvanced, generateInitialStoryBasic, generateMany,
  generateParagraph, setGraph, requestComplete, progressUpdate, openAIError, rateLimitError, disconnectedError, nlpParseError
} from './storySlice';
import { connectionEstablished, disconnected, startConnecting } from './wsSlice';

enum ResponseType {
  RequestComplete = "requestComplete",
  ProgressUpdate = "progressUpdate",
  RateLimitError = "rateLimitError",
  OpenAIError = "openaiError",
  NlpParseError = "nlpParseError",
};

type Response = {
  resType: ResponseType,
};

type RequestCompleteResponse = {
  graph: GraphMessage,
};

type ProgressUpdateResponse = {
  graph: GraphMessage,
  numNodesGenerated: number,
  percentage: number,
};


const wsMiddleware: Middleware = store => {
  let socket: WebSocket;

  return next => action => {
    const state = store.getState();
    const isConnectionEstablished = socket && state.ws.isConnected;
    const connecting = socket && state.ws.isEstablishingConnection;

    if (startConnecting.match(action) && !isConnectionEstablished && !connecting) {
      socket = new WebSocket(WS_URL);

      socket.onopen = () => {
        store.dispatch(connectionEstablished());
      };

      socket.onmessage = (msg) => {
        const jsonMsg = JSON.parse(msg.data);

        const resType = (jsonMsg as Response).resType;

        if (resType === ResponseType.RequestComplete) {
          const msg = jsonMsg as RequestCompleteResponse;

          const graph = graphMessageToGraphLookup(msg.graph);
          store.dispatch(setGraph(graph));
          store.dispatch(requestComplete());
        } else if (resType === ResponseType.ProgressUpdate) {
          const msg = jsonMsg as ProgressUpdateResponse;

          const graph = graphMessageToGraphLookup(msg.graph);
          store.dispatch(setGraph(graph));
          store.dispatch(progressUpdate(
            { percentage: msg.percentage, numNodesGenerated: msg.numNodesGenerated }
          ));
        } else if (resType === ResponseType.OpenAIError) {
          store.dispatch(openAIError());
        } else if (resType === ResponseType.RateLimitError) {
          store.dispatch(rateLimitError());
        } else if (resType === ResponseType.NlpParseError) {
          store.dispatch(nlpParseError());
        }
      };

      socket.onclose = () => {
        store.dispatch(disconnected());
        store.dispatch(disconnectedError());
        // reconnect in 2 seconds
        setTimeout(() => {
          store.dispatch(startConnecting());
        }, 3000)
      };
    }

    if (isConnectionEstablished) {
      if (generateInitialStoryBasic.match(action)) {
        const values = [{ attribute: "theme", content: action.payload.prompt }];
        socket.send(generateInitialStoryMsg(state.story.temperature, values));
      }

      if (generateInitialStoryAdvanced.match(action)) {
        socket.send(generateInitialStoryMsg(state.story.temperature, action.payload.values));
      }

      if (generateActions.match(action)) {
        socket.send(generateActionsMsg(state.story.temperature, state.story.graph, action.payload.nodeToExpand));
      }

      if (generateNewAction.match(action)) {
        socket.send(addActionMsg(state.story.temperature, state.story.graph, action.payload.nodeToExpand, state.story.numActionsToAdd))
      }

      if (generateParagraph.match(action)) {
        socket.send(generateNarrativeMsg(
          state.story.temperature,
          state.story.graph,
          action.payload.nodeToExpand,
          false,
          state.story.descriptor,
          state.story.details,
          state.story.style));
      }

      if (generateEnding.match(action)) {
        socket.send(generateNarrativeMsg(
          state.story.temperature,
          state.story.graph,
          action.payload.nodeToEnd,
          true,
          state.story.descriptor,
          state.story.details,
          state.story.style));
      }

      if (connectNodesWithMiddle.match(action)) {
        socket.send(connectNodesMsg(
          state.story.temperature,
          state.story.graph,
          action.payload.fromNode,
          action.payload.toNode
        ));
      }

      if (generateMany.match(action)) {
        socket.send(generateManyMsg(
          state.story.temperature,
          state.story.graph,
          action.payload.fromNode,
          state.story.generateManyDepth,
          state.story.storyId
        ));
      }
    } else if (
      generateInitialStoryBasic.match(action)
      || generateInitialStoryAdvanced.match(action)
      || generateActions.match(action)
      || generateNewAction.match(action)
      || generateParagraph.match(action)
      || generateEnding.match(action)
      || connectNodesWithMiddle.match(action)
      || generateMany.match(action)
    ) {
      store.dispatch(disconnectedError());
    }
    next(action);
  }
}

export default wsMiddleware;
