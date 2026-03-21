import { createSlice, PayloadAction } from '@reduxjs/toolkit'
import { nodeDataToGraph } from '../../graph/graphUtils';
import { Graph, NodeData } from '../../graph/types';

interface StoryState {
  graph: Graph;
}

// For testing.
const nodeData: NodeData[] = [
  {
    nodeId: 0,
    action: null,
    paragraph: "This is the initial paragraph",
    parentId: null,
    childrenIds: [1, 240],
  },
  {
    nodeId: 1,
    action: "Go to sleep",
    paragraph: "This is the 2nd paragraph",
    parentId: 0,
    childrenIds: [3],
  },
  {
    nodeId: 240,
    action: "Go to the Huxley dungeon",
    paragraph: "This is the 3rd paragraph",
    parentId: 0,
    childrenIds: [4],
  },
  {
    nodeId: 3,
    action: "Wake up",
    paragraph: "You can wake up now",
    parentId: 1,
    childrenIds: [],
  },
  {
    nodeId: 4,
    action: "Get out",
    paragraph: "You are in the dungeon",
    parentId: 4,
    childrenIds: [],
  },
];

// const nodeData: NodeData[] = [
//   {
//     nodeId: 0,
//     action: null,
//     paragraph: "You are a commoner living in the large kingdom of Garion. Your kingdom has been in bitter war with the neighboring kingdom, Liore, for the past year. You dream of doing something great and going on an adventure. You walk around town and see warning posters about the dangers of the dark forest at the edge of town. You go to the market and see military representatives signing people up for the army.",
//     parentId: null,
//     childrenIds: [],
//   },
// ];

const initialState: StoryState = {
  graph: nodeDataToGraph(nodeData),
}

export const storySlice = createSlice({
  name: 'story',
  initialState,
  reducers: {
    setNodeData: (state, action: PayloadAction<NodeData[]>) => {
      state.graph = nodeDataToGraph(action.payload);
    },
  },
});

export const { setNodeData } = storySlice.actions;

export default storySlice.reducer;
