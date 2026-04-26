/**
 * NarrativeSection — read-only narrative paragraph rendered inside a
 * `FlowNodeNarrative` on the canvas.
 *
 * Presentational: takes a `NarrativeNode`. Click handling lives on the
 * surrounding flow node.
 */

import { Badge, Box, Text } from "@mantine/core";

import type { NarrativeNode } from "../../../../types";

type Props = {
  node: NarrativeNode;
};

const PLACEHOLDER = "No content yet.";

const NarrativeSection = ({ node }: Props) => {
  return (
    <Box>
      <Text size="sm" lineClamp={5}>
        {node.data || PLACEHOLDER}
      </Text>
      {node.isEnding && (
        <Badge color="red" size="xs" mt={4}>
          Ending
        </Badge>
      )}
    </Box>
  );
};

export default NarrativeSection;
