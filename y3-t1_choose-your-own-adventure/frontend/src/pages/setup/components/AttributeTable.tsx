/**
 * AttributeTable — list of `InputTextForm` rows plus an "Add row" button.
 *
 * Presentational: callers provide the rows and the four callbacks.
 */

import { Button, Stack, Title } from "@mantine/core";
import { IconPlus } from "@tabler/icons-react";

import type { AttributeRow } from "../slices/setup";
import InputTextForm from "./InputTextForm";

type Props = {
  rows: AttributeRow[];
  onAttribute: (position: number, value: string) => void;
  onContent: (position: number, value: string) => void;
  onAdd: () => void;
  onRemove: (position: number) => void;
  disabled?: boolean;
};

const AttributeTable = ({
  rows,
  onAttribute,
  onContent,
  onAdd,
  onRemove,
  disabled,
}: Props) => {
  return (
    <Stack gap="md">
      <Title order={4}>Attributes</Title>
      {rows.map((row, position) => (
        <InputTextForm
          key={position}
          attribute={row.attribute}
          content={row.content}
          onAttribute={(v) => onAttribute(position, v)}
          onContent={(v) => onContent(position, v)}
          onRemove={() => onRemove(position)}
          disabled={disabled}
        />
      ))}
      <Button
        variant="light"
        leftSection={<IconPlus size={16} />}
        onClick={onAdd}
        disabled={disabled}
      >
        Add attribute
      </Button>
    </Stack>
  );
};

export default AttributeTable;
