/**
 * GraphCanvas — ReactFlow-based interactive view of the story graph.
 *
 * Reads the in-memory `Graph` from the slice, lays it out via dagre, and
 * renders it as a node/edge diagram. Click to select; right-click for the
 * context menu (delete / expand / disconnect).
 */

import {
  Background,
  Controls,
  ReactFlow,
  type NodeMouseHandler,
  useEdgesState,
  useNodesState,
} from "@xyflow/react";
import { useCallback, useEffect, useState } from "react";

import { useAppDispatch, useAppSelector } from "../../../../store/hooks";
import {
  deleteNode,
  generateMany,
  selectActiveNodeId,
  selectGraph,
  setActiveNodeId,
} from "../../slices/graph";
import FlowNodeAction from "./FlowNodeAction";
import FlowNodeNarrative from "./FlowNodeNarrative";
import GraphContextMenu from "./GraphContextMenu";
import { dagreLayout } from "./graphLayout";
import { graphToFlowEdges } from "./graphEdges";
import { graphToFlowNodes } from "./graphNodes";

const nodeTypes = {
  narrative: FlowNodeNarrative,
  action: FlowNodeAction,
};

type ContextMenuState = {
  x: number;
  y: number;
  nodeId: number;
};

const GraphCanvas = () => {
  const dispatch = useAppDispatch();
  const graph = useAppSelector(selectGraph);
  const activeNodeId = useAppSelector(selectActiveNodeId);

  // Initial layout runs at first render; the `useEffect` below recomputes on
  // every graph mutation so the canvas stays in sync with slice state.
  const [nodes, setNodes, onNodesChange] = useNodesState(
    dagreLayout(graphToFlowNodes(graph), graphToFlowEdges(graph)),
  );
  const [edges, setEdges, onEdgesChange] = useEdgesState(
    graphToFlowEdges(graph),
  );
  const [contextMenu, setContextMenu] = useState<ContextMenuState | null>(null);

  // Re-layout whenever the graph mutates.
  useEffect(() => {
    const flowNodes = graphToFlowNodes(graph).map((n) => ({
      ...n,
      selected: parseInt(n.id, 10) === activeNodeId,
    }));
    const flowEdges = graphToFlowEdges(graph);
    setNodes(dagreLayout(flowNodes, flowEdges));
    setEdges(flowEdges);
  }, [graph, activeNodeId, setNodes, setEdges]);

  const onNodeClick: NodeMouseHandler = useCallback(
    (_, node) => {
      dispatch(setActiveNodeId(parseInt(node.id, 10)));
    },
    [dispatch],
  );

  const onNodeContextMenu: NodeMouseHandler = useCallback(
    (event, node) => {
      event.preventDefault();
      setContextMenu({
        x: event.clientX,
        y: event.clientY,
        nodeId: parseInt(node.id, 10),
      });
    },
    [],
  );

  if (Object.keys(graph.nodeLookup).length === 0) {
    return (
      <div
        style={{
          height: 500,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          color: "#868e96",
        }}
      >
        No content yet — generate the first paragraph from the toolbar.
      </div>
    );
  }

  return (
    <div style={{ width: "100%", height: 500 }}>
      <ReactFlow
        nodes={nodes}
        edges={edges}
        nodeTypes={nodeTypes}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        onNodeClick={onNodeClick}
        onNodeContextMenu={onNodeContextMenu}
        fitView
        nodesDraggable={false}
        proOptions={{ hideAttribution: true }}
      >
        <Background />
        <Controls showInteractive={false} />
      </ReactFlow>
      {contextMenu && (
        <GraphContextMenu
          position={{ x: contextMenu.x, y: contextMenu.y }}
          onClose={() => setContextMenu(null)}
          onDelete={
            contextMenu.nodeId !== 0
              ? () => dispatch(deleteNode(contextMenu.nodeId))
              : undefined
          }
          onExpand={() => dispatch(generateMany(contextMenu.nodeId))}
        />
      )}
    </div>
  );
};

export default GraphCanvas;
