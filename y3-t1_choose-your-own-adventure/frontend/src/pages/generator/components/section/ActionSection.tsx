/**
 * ActionSection — read-only action choice rendered inside a `FlowNodeAction`.
 */

import { Box, Text } from "@mantine/core";

import type { ActionNode } from "../../../../types";

type Props = {
  node: ActionNode;
};

const PLACEHOLDER = "No action yet.";

const ActionSection = ({ node }: Props) => {
  return (
    <Box>
      <Text size="sm" fs="italic" c="dimmed" lineClamp={3}>
        ▸ {node.data || PLACEHOLDER}
      </Text>
    </Box>
  );
};

export default ActionSection;
