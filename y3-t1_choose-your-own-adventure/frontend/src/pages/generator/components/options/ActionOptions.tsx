/**
 * ActionOptions — actions available on a selected action node.
 */

import { Button, Stack, Textarea, Title } from "@mantine/core";

import type { ActionNode } from "../../../../types";
import { useAppDispatch, useAppSelector } from "../../../../store/hooks";
import {
  deleteNode,
  generateNarrative,
  setNodeData,
} from "../../slices/graph";
import { selectIsLoading } from "../../slices/loading";

type Props = {
  node: ActionNode;
};

const ActionOptions = ({ node }: Props) => {
  const dispatch = useAppDispatch();
  const isLoading = useAppSelector(selectIsLoading);

  return (
    <Stack gap="sm">
      <Title order={5}>Action</Title>
      <Textarea
        autosize
        minRows={2}
        value={node.data}
        onChange={(e) =>
          dispatch(
            setNodeData({ nodeId: node.nodeId, data: e.currentTarget.value }),
          )
        }
      />
      <Button
        onClick={() =>
          dispatch(generateNarrative({ nodeId: node.nodeId, isEnding: false }))
        }
        disabled={isLoading}
      >
        Continue narrative
      </Button>
      <Button
        variant="light"
        onClick={() =>
          dispatch(generateNarrative({ nodeId: node.nodeId, isEnding: true }))
        }
        disabled={isLoading}
      >
        Generate ending
      </Button>
      <Button
        color="red"
        variant="light"
        onClick={() => dispatch(deleteNode(node.nodeId))}
      >
        Delete action
      </Button>
    </Stack>
  );
};

export default ActionOptions;
