import {
  ActionIcon, Group, Text, Textarea
} from '@mantine/core';
import { IconCheckbox, IconEdit } from '@tabler/icons-react';
import React, { useEffect, useState } from 'react';
import { decrementNumOfEdits, incrementNumOfEdits, resetNumOfEdits, selectGraphIsLoading, setNodeData } from '../../store/features/storySlice';
import { useAppDispatch, useAppSelector } from '../../store/hooks';
import classes from './EditableField.module.css';


interface EditableFieldProps {
  value: string;
  nodeId: number;
  disabled?: boolean;
  className?: string;
}

const EditableField = (props: EditableFieldProps) => {
  const dispatch = useAppDispatch();
  const graphIsLoading = useAppSelector(selectGraphIsLoading);

  const [text, setText] = useState(props.value);
  const [editable, setEditable] = useState(false);

  const editIsDisabled = props.disabled ?? graphIsLoading;

  useEffect(() => {
    setText(props.value);
  }, [props.value]);

  useEffect(() => {
    setEditable(false);
    dispatch(resetNumOfEdits());
  }, [props.nodeId]);

  const handleTextChange = (event: React.ChangeEvent<HTMLTextAreaElement>): void => {
    setText(event.target.value);
  };

  const onEditClick = (): void => {
    dispatch(incrementNumOfEdits());
    setEditable(true);
  };

  const onDoneClick = (): void => {
    setEditable(false);
    dispatch(setNodeData({ nodeId: props.nodeId, data: text }));
    dispatch(decrementNumOfEdits());
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
      <Text className={props.className || classes.text}>
        {props.value}
      </Text>
      <ActionIcon onClick={onEditClick} disabled={editIsDisabled}>
        <IconEdit />
      </ActionIcon>
    </Group>
  );
};

export default EditableField;
