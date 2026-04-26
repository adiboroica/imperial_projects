/**
 * FlowNodeAction — custom ReactFlow node for action choices.
 */

import { Paper } from "@mantine/core";
import { Handle, type NodeProps, Position } from "@xyflow/react";

import type { ActionNode } from "../../../../types";
import ActionSection from "../section/ActionSection";

type FlowNodeActionData = {
  node: ActionNode;
};

const FlowNodeAction = ({ data, selected }: NodeProps) => {
  const { node } = data as unknown as FlowNodeActionData;
  return (
    <>
      <Handle type="target" position={Position.Top} />
      <Paper
        withBorder
        p="xs"
        radius="sm"
        style={{
          width: 240,
          minHeight: 70,
          backgroundColor: "#f8f9fa",
          borderColor: selected ? "#228be6" : undefined,
          borderWidth: selected ? 2 : 1,
        }}
      >
        <ActionSection node={node} />
      </Paper>
      <Handle type="source" position={Position.Bottom} />
    </>
  );
};

export default FlowNodeAction;
