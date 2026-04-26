/**
 * AdvancedOptionArea — expandable panel for descriptor/details/style/temperature.
 */

import {
  Collapse,
  Slider,
  Stack,
  Switch,
  Text,
  TextInput,
  Textarea,
} from "@mantine/core";
import { useState } from "react";

import { useAppDispatch, useAppSelector } from "../../../../store/hooks";
import {
  selectDescriptor,
  selectDetails,
  selectStyle,
  selectTemperature,
  setDescriptor,
  setDetails,
  setStyle,
  setTemperature,
} from "../../slices/params";

const AdvancedOptionArea = () => {
  const dispatch = useAppDispatch();
  const descriptor = useAppSelector(selectDescriptor);
  const details = useAppSelector(selectDetails);
  const style = useAppSelector(selectStyle);
  const temperature = useAppSelector(selectTemperature);

  const [open, setOpen] = useState(false);

  return (
    <Stack gap="xs">
      <Switch
        label="Advanced options"
        checked={open}
        onChange={(e) => setOpen(e.currentTarget.checked)}
      />
      <Collapse in={open}>
        <Stack gap="xs" mt="xs">
          <div>
            <Text size="xs" fw={600} mb={4}>
              Creativity
            </Text>
            <Slider
              value={temperature}
              onChange={(v) => dispatch(setTemperature(v))}
              min={0}
              max={1}
              step={0.05}
              size="sm"
            />
          </div>
          <TextInput
            label="Descriptor"
            placeholder="e.g. mysterious, action-packed"
            value={descriptor}
            onChange={(e) => dispatch(setDescriptor(e.currentTarget.value))}
          />
          <Textarea
            label="Details"
            placeholder="Specific events or constraints"
            value={details}
            onChange={(e) => dispatch(setDetails(e.currentTarget.value))}
            autosize
            minRows={2}
          />
          <TextInput
            label="Style"
            placeholder="e.g. terse, lyrical"
            value={style}
            onChange={(e) => dispatch(setStyle(e.currentTarget.value))}
          />
        </Stack>
      </Collapse>
    </Stack>
  );
};

export default AdvancedOptionArea;
