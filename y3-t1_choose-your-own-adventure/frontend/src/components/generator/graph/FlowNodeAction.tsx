import {
  Text,
  createStyles,
  Group,
  Box,
} from '@mantine/core';
import { Handle, NodeProps, Position } from 'reactflow';
import { ActionNode } from '../../../utils/graph/types';

const boxSize = {
  width: 172,
  height: 64,
};

const useStyles = createStyles((theme) => ({

  nodeBox: {
    // theme.colors.gray[0] -> #f8f9fa ->
    backgroundColor: "rgba(248, 249, 250, 0.2)",
    border: `2px solid ${theme.colors.gray[0]}`,
    textAlign: 'center',
    padding: theme.spacing.md,
    borderRadius: "100%",
    maxWidth: boxSize.width,
    maxHeight: boxSize.height,
    fontSize: "10px",
    overflow: "hidden",

    '&:hover': {
      cursor: "pointer",
    },
  },
}));


interface ActionFlowNodeData {
  actionNode: ActionNode,
};

function ActionFlowNode(props: NodeProps<ActionFlowNodeData>) {
  const { classes } = useStyles();

  const {
    data: {
      actionNode,
    },
    targetPosition,
    sourcePosition,
  } = props;

  // node-box required for change on hover
  const boxClasses = `${classes.nodeBox} node-box`;

  return (
    <Box className={boxClasses}>
      <Handle type="target" position={targetPosition || Position.Top} />
      <Group noWrap={true} align="top">
        <Text lineClamp={2}>
          {actionNode.data}
        </Text>
      </Group>
      <Handle type="source" position={sourcePosition || Position.Bottom} />
    </Box>
  );
}

export default ActionFlowNode;
