import {
  Text,
  Group,
  Box,
} from '@mantine/core';
import { Handle, NodeProps, Position } from '@xyflow/react';
import { NarrativeNode } from '../../../../utils/graph/types';
import classes from './FlowNodeNarrative.module.css';


interface NarrativeFlowNodeData {
  narrativeNode: NarrativeNode,
};

function NarrativeFlowNode(props: NodeProps) {
  const {
    data,
    targetPosition,
    sourcePosition,
  } = props;

  const narrativeNode = data.narrativeNode as NarrativeNode;

  // node-box required for change on hover
  const boxClasses = `${classes.nodeBox} node-box`;

  return (
    <Box className={boxClasses}>
      <Handle type="target" position={targetPosition || Position.Top} />
      <Group wrap="nowrap" align="top">
        <Text lineClamp={2}>
          {narrativeNode.data}
        </Text>
      </Group>
      <Handle type="source" position={sourcePosition || Position.Bottom} />
    </Box>
  );
}

export default NarrativeFlowNode;
