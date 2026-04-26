/**
 * InputTextForm — a single attribute row: attribute name + content + remove.
 *
 * Presentational: takes the row's current values plus three callbacks.
 */

import { ActionIcon, Group, TextInput } from "@mantine/core";
import { IconTrash } from "@tabler/icons-react";

type Props = {
  attribute: string;
  content: string;
  onAttribute: (value: string) => void;
  onContent: (value: string) => void;
  onRemove: () => void;
  disabled?: boolean;
};

const InputTextForm = ({
  attribute,
  content,
  onAttribute,
  onContent,
  onRemove,
  disabled,
}: Props) => {
  return (
    <Group align="end" wrap="nowrap">
      <TextInput
        label="Attribute"
        value={attribute}
        onChange={(e) => onAttribute(e.currentTarget.value)}
        style={{ flex: 1 }}
        disabled={disabled}
      />
      <TextInput
        label="Content"
        value={content}
        onChange={(e) => onContent(e.currentTarget.value)}
        style={{ flex: 2 }}
        disabled={disabled}
      />
      <ActionIcon
        color="red"
        variant="light"
        onClick={onRemove}
        aria-label="Remove attribute"
        disabled={disabled}
        size="lg"
      >
        <IconTrash size={18} />
      </ActionIcon>
    </Group>
  );
};

export default InputTextForm;
