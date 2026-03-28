import {
  Text,
  Group,
  Box,
} from '@mantine/core';
import { Handle, NodeProps, Position } from '@xyflow/react';
import { ActionNode } from '../../../../utils/graph/types';
import classes from './FlowNodeAction.module.css';


interface ActionFlowNodeData {
  actionNode: ActionNode,
};

function ActionFlowNode(props: NodeProps) {
  const {
    data,
    targetPosition,
    sourcePosition,
  } = props;

  const actionNode = data.actionNode as ActionNode;

  // node-box required for change on hover
  const boxClasses = `${classes.nodeBox} node-box`;

  return (
    <Box className={boxClasses}>
      <Handle type="target" position={targetPosition || Position.Top} />
      <Group wrap="nowrap" align="top">
        <Text lineClamp={2}>
          {actionNode.data}
        </Text>
      </Group>
      <Handle type="source" position={sourcePosition || Position.Bottom} />
    </Box>
  );
}

export default ActionFlowNode;
