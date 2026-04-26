/**
 * Graph toolbar — generation knobs + summary actions.
 */

import { Group, NumberInput, Slider, Stack, Text } from "@mantine/core";

import { useAppDispatch, useAppSelector } from "../../../../store/hooks";
import {
  selectGenerateManyDepth,
  selectNumActionsToAdd,
  selectTemperature,
  setGenerateManyDepth,
  setNumActionsToAdd,
  setTemperature,
} from "../../slices/params";

type Props = {
  storyId: string;
};

const GraphToolbar = ({ storyId }: Props) => {
  const dispatch = useAppDispatch();
  const temperature = useAppSelector(selectTemperature);
  const depth = useAppSelector(selectGenerateManyDepth);
  const numActions = useAppSelector(selectNumActionsToAdd);

  return (
    <Stack gap="xs">
      <Group gap="xl" wrap="wrap">
        <Stack gap={4} miw={200}>
          <Text size="xs" fw={600}>
            Creativity
          </Text>
          <Slider
            value={temperature}
            onChange={(v) => dispatch(setTemperature(v))}
            min={0}
            max={1}
            step={0.05}
            marks={[
              { value: 0, label: "0" },
              { value: 0.5, label: "0.5" },
              { value: 1, label: "1" },
            ]}
          />
        </Stack>
        <NumberInput
          label="Action count"
          min={1}
          max={5}
          value={numActions}
          onChange={(v) =>
            dispatch(setNumActionsToAdd(typeof v === "number" ? v : 1))
          }
        />
        <NumberInput
          label="Bulk depth"
          min={1}
          max={5}
          value={depth}
          onChange={(v) =>
            dispatch(setGenerateManyDepth(typeof v === "number" ? v : 1))
          }
        />
      </Group>
      <Text size="xs" c="dimmed">
        Story id: <code>{storyId}</code>
      </Text>
    </Stack>
  );
};

export default GraphToolbar;
