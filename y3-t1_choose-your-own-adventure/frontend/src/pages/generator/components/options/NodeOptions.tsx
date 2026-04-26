/**
 * NodeOptions — side panel for the currently-selected node.
 *
 * Dispatches on node type to `NarrativeOptions` or `ActionOptions`, then
 * always renders the shared `AdvancedOptionArea` underneath.
 */

import { Stack, Text, Title } from "@mantine/core";

import { isNarrativeNode } from "../../../../types";
import { useAppSelector } from "../../../../store/hooks";
import { selectActiveNodeId, selectGraph } from "../../slices/graph";
import ActionOptions from "./ActionOptions";
import AdvancedOptionArea from "./AdvancedOptionArea";
import NarrativeOptions from "./NarrativeOptions";

const NodeOptions = () => {
  const graph = useAppSelector(selectGraph);
  const activeNodeId = useAppSelector(selectActiveNodeId);
  const node = graph.nodeLookup[activeNodeId];

  if (!node) {
    return (
      <Stack>
        <Title order={5}>Selected node</Title>
        <Text c="dimmed" size="sm">
          Click a paragraph or action in the canvas to inspect it.
        </Text>
        <AdvancedOptionArea />
      </Stack>
    );
  }

  return (
    <Stack gap="md">
      {isNarrativeNode(node) ? (
        <NarrativeOptions node={node} />
      ) : (
        <ActionOptions node={node} />
      )}
      <AdvancedOptionArea />
    </Stack>
  );
};

export default NodeOptions;
