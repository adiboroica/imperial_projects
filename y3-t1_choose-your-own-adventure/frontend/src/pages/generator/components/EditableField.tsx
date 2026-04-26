import { ActionIcon, Group, Text, Textarea } from "@mantine/core";
import { IconCheckbox, IconEdit } from "@tabler/icons-react";
import React, { useEffect, useState } from "react";

import classes from "./EditableField.module.css";

interface EditableFieldProps {
  value: string;
  /** Optional callback fired when the user commits an edit. */
  onCommit?: (next: string) => void;
  /** Disable the edit affordance. */
  disabled?: boolean;
  className?: string;
}

/**
 * Click-to-edit text input. Reads its value from props and fires `onCommit`
 * when the user confirms the change.
 */
const EditableField = (props: EditableFieldProps) => {
  const [text, setText] = useState(props.value);
  const [editable, setEditable] = useState(false);

  useEffect(() => {
    setText(props.value);
  }, [props.value]);

  useEffect(() => {
    setEditable(false);
  }, [props.value]);

  const handleTextChange = (
    event: React.ChangeEvent<HTMLTextAreaElement>,
  ): void => {
    setText(event.target.value);
  };

  const onEditClick = () => setEditable(true);

  const onDoneClick = () => {
    setEditable(false);
    if (props.onCommit && text !== props.value) {
      props.onCommit(text);
    }
  };

  if (editable) {
    return (
      <Group wrap="nowrap" align="center">
        <Textarea
          size="md"
          autosize
          minRows={2}
          maxRows={6}
          value={text}
          onChange={handleTextChange}
          className={classes.textInput}
        />
        <ActionIcon onClick={onDoneClick}>
          <IconCheckbox color="blue" />
        </ActionIcon>
      </Group>
    );
  }

  return (
    <Group wrap="nowrap" align="center">
      <Text className={props.className || classes.text}>{props.value}</Text>
      <ActionIcon onClick={onEditClick} disabled={props.disabled}>
        <IconEdit />
      </ActionIcon>
    </Group>
  );
};

export default EditableField;
