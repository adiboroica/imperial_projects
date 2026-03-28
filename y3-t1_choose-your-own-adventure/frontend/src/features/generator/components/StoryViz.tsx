import {
  Container, Group, Pagination
} from "@mantine/core";
import { memo, useCallback, useEffect, useMemo } from "react";
import {
  connectNodes, connectNodesWithMiddle, deleteEdge,
  selectActiveNodeId, selectLoadingType, selectStoryGraph, setActiveNodeId
} from "../../../store/features/storySlice";
import { useAppDispatch, useAppSelector } from "../../../store/hooks";
import { isAction } from "../../../utils/graph/graphUtils";
import { getStoryNodes } from "../../../utils/graph/storyUtils";
import { NodeData, StoryNode } from "../../../utils/graph/types";
import GraphViz from "./graph/GraphViz";
import NodeOptions from "./options/NodeOptions";
import StorySection from "./StorySection";
import classes from './StoryViz.module.css';


function StoryViz() {

  const dispatch = useAppDispatch();
  const storyGraph = useAppSelector(selectStoryGraph);
  const loadingType = useAppSelector(selectLoadingType);

  const activeNodeId = useAppSelector(selectActiveNodeId);

  const setActiveNodeIdLocal = useCallback((id: number) => {
    dispatch(setActiveNodeId(id));
  }, [dispatch])


  useEffect(() => {
    setActiveNodeIdLocal(0);
  }, []);


  /****************************************************************
  **** Functions.
  ****************************************************************/

  const sendConnectNodesMessage = useCallback((
    fromNode: number,
    toNode: number,
    generateMiddleNode: boolean
  ) => {
    if (!generateMiddleNode) {
      dispatch(connectNodes({ fromNode, toNode }));
      return;
    }

    // Block if there are other requests.
    if (loadingType !== null)
      return;

    dispatch(connectNodesWithMiddle({ fromNode, toNode }))
  }, [dispatch, loadingType])

  const onEdgeDelete = useCallback((fromNode: number, toNode: number) => {
    dispatch(deleteEdge({ fromNode, toNode }));
  }, [dispatch])


  /****************************************************************
  **** Data.
  ****************************************************************/

  const story = useMemo(() => {
    return getStoryNodes(storyGraph, false);
  },
    [storyGraph]
  );

  const activeSectionId = useMemo(() => {
    if (activeNodeId === null) {
      return 0;
    }

    const node: NodeData = storyGraph.nodeLookup[activeNodeId];

    if (isAction(node)) {
      const parentNarrativeNode = Object.values(storyGraph.nodeLookup)
        .find((parent: NodeData) => parent.childrenIds.includes(activeNodeId))!
      return story.find((node) => node.nodeId === parentNarrativeNode.nodeId)!.sectionId;
    }

    return story.find((storyNode) => storyNode.nodeId === node.nodeId)!.sectionId;
  },
    [story, storyGraph, activeNodeId]
  );

  const setActiveSectionId = useCallback((page: number) => {
    const storyNode: StoryNode = story.find((storyNode) => storyNode.sectionId === page)!
    setActiveNodeIdLocal(storyNode.nodeId);
  },
    [story, setActiveNodeIdLocal]
  );

  const activeStory = useMemo(() => {
    return story.find((storyNode) => storyNode.sectionId === activeSectionId)
  },
    [story, activeSectionId]
  );

  const Graph = useMemo(() => {
    return (
      <GraphViz
        setActiveNodeId={setActiveNodeIdLocal}
        onConnectNodes={sendConnectNodesMessage}
        onEdgeDelete={onEdgeDelete}
      />
    )
  }, [setActiveNodeIdLocal, sendConnectNodesMessage, onEdgeDelete])


  /****************************************************************
  **** Return.
  ****************************************************************/

  return (
    <Container className={classes.container}>
      <Group gap="xl" className={classes.group}>

        {Graph}

        <Container className={classes.optionsContainer}>
          {activeNodeId !== null &&
            <NodeOptions nodeData={storyGraph.nodeLookup[activeNodeId!]} />
          }
        </Container>

      </Group>

      <Group justify="center">
        <Pagination
          value={activeSectionId}
          onChange={setActiveSectionId}
          total={story.length}
          siblings={3}
          radius="lg"
          withEdges
        />
      </Group>
      <StorySection {...activeStory!} />

    </Container>
  );
}

export default memo(StoryViz);
