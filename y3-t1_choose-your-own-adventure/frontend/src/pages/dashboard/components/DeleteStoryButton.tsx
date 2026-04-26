/**
 * Confirmation-wrapped delete trigger.
 */

import { ActionIcon, Group, Popover, Text } from "@mantine/core";
import { IconTrash } from "@tabler/icons-react";
import { useState } from "react";

type Props = {
  onConfirm: () => void;
  disabled?: boolean;
};

const DeleteStoryButton = ({ onConfirm, disabled }: Props) => {
  const [open, setOpen] = useState(false);

  return (
    <Popover opened={open} onChange={setOpen} position="left" withArrow>
      <Popover.Target>
        <ActionIcon
          color="red"
          variant="light"
          size="lg"
          aria-label="Delete story"
          disabled={disabled}
          onClick={() => setOpen((v) => !v)}
        >
          <IconTrash size={18} />
        </ActionIcon>
      </Popover.Target>
      <Popover.Dropdown>
        <Text size="sm" mb="xs">
          Delete this story? This cannot be undone.
        </Text>
        <Group gap="xs">
          <ActionIcon
            color="gray"
            variant="light"
            onClick={() => setOpen(false)}
          >
            Cancel
          </ActionIcon>
          <ActionIcon
            color="red"
            onClick={() => {
              setOpen(false);
              onConfirm();
            }}
          >
            Delete
          </ActionIcon>
        </Group>
      </Popover.Dropdown>
    </Popover>
  );
};

export default DeleteStoryButton;
