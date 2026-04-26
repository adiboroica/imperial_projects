/**
 * FlowNodeNarrative — custom ReactFlow node for narrative paragraphs.
 *
 * Wraps a `<NarrativeSection>` in a Paper card with top/bottom handles for
 * edge endpoints.
 */

import { Paper } from "@mantine/core";
import { Handle, type NodeProps, Position } from "@xyflow/react";

import type { NarrativeNode } from "../../../../types";
import NarrativeSection from "../section/NarrativeSection";

type FlowNodeNarrativeData = {
  node: NarrativeNode;
};

const FlowNodeNarrative = ({ data, selected }: NodeProps) => {
  const { node } = data as unknown as FlowNodeNarrativeData;
  return (
    <>
      <Handle type="target" position={Position.Top} />
      <Paper
        withBorder
        p="xs"
        radius="sm"
        style={{
          width: 240,
          minHeight: 90,
          borderColor: selected ? "#228be6" : undefined,
          borderWidth: selected ? 2 : 1,
        }}
      >
        <NarrativeSection node={node} />
      </Paper>
      <Handle type="source" position={Position.Bottom} />
    </>
  );
};

export default FlowNodeNarrative;
