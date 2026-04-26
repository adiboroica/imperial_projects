/**
 * NarrativeOptions — actions available on a selected narrative node.
 */

import { Button, Stack, Switch, Textarea, Title } from "@mantine/core";

import type { NarrativeNode } from "../../../../types";
import { useAppDispatch, useAppSelector } from "../../../../store/hooks";
import {
  addAction,
  deleteNode,
  generateActions,
  generateMany,
  setEnding,
  setNodeData,
} from "../../slices/graph";
import { selectIsLoading } from "../../slices/loading";

type Props = {
  node: NarrativeNode;
};

const NarrativeOptions = ({ node }: Props) => {
  const dispatch = useAppDispatch();
  const isLoading = useAppSelector(selectIsLoading);

  return (
    <Stack gap="sm">
      <Title order={5}>Narrative</Title>
      <Textarea
        autosize
        minRows={3}
        value={node.data}
        onChange={(e) =>
          dispatch(
            setNodeData({ nodeId: node.nodeId, data: e.currentTarget.value }),
          )
        }
      />
      <Switch
        label="Mark as ending"
        checked={node.isEnding}
        onChange={(e) =>
          dispatch(
            setEnding({
              nodeId: node.nodeId,
              isEnding: e.currentTarget.checked,
            }),
          )
        }
      />
      <Button
        onClick={() => dispatch(generateActions(node.nodeId))}
        disabled={isLoading || node.isEnding}
      >
        Generate actions
      </Button>
      <Button
        variant="light"
        onClick={() => dispatch(addAction(node.nodeId))}
        disabled={isLoading || node.isEnding}
      >
        Add another action
      </Button>
      <Button
        variant="light"
        onClick={() => dispatch(generateMany(node.nodeId))}
        disabled={isLoading || node.isEnding}
      >
        Bulk-expand subtree
      </Button>
      <Button
        color="red"
        variant="light"
        onClick={() => dispatch(deleteNode(node.nodeId))}
        disabled={node.nodeId === 0}
      >
        Delete node
      </Button>
    </Stack>
  );
};

export default NarrativeOptions;
