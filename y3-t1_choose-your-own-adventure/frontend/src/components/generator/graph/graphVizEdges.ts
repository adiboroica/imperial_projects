const edgeType = 'default';

interface flowEdgeArgs {
  nodeId: number,
  childId: number,
}

export const flowEdge = (args: flowEdgeArgs) => {

  const {
    nodeId,
    childId
  } = args;

  return (
    {
      id: `e${nodeId}${childId}`,
      source: `${nodeId}`,
      target: `${childId}`,
      type: edgeType,
      animated: true
    }
  );
}