import {
  ActionIcon, createStyles, Group, Text, Textarea
} from '@mantine/core';
import { IconCheckbox, IconEdit } from '@tabler/icons';
import React, { useEffect, useState } from 'react';
import { decrementNumOfEdits, incrementNumOfEdits, resetNumOfEdits, selectGraphIsLoading, setNodeData } from '../../../store/features/storySlice';
import { useAppDispatch, useAppSelector } from '../../../store/hooks';


const useStyles = createStyles((theme) => ({
  action: {
    color: theme.black,
    wordBreak: "break-word",
    overflowWrap: "break-word",
    hyphens: "auto",
  },

  text_input: {
    width: "100%",
    numberOfLines: 5
  }
}));


interface ActionSectionProps {
  nodeId: number,
  action: string,
};

const ActionSection = (props: ActionSectionProps) => {
  const { classes } = useStyles();

  const dispatch = useAppDispatch();
  const graphIsLoading = useAppSelector(selectGraphIsLoading);

  const [action, setAction] = useState(props.action);
  const [editable, setEditable] = useState(false);

  const editIsDisabled = graphIsLoading;


  /****************************************************************
  **** Effects.
  ****************************************************************/

  useEffect(() => {
    setEditable(false);
    dispatch(resetNumOfEdits());
  }, [props.nodeId]);


  /****************************************************************
  **** Functions.
  ****************************************************************/

  const handleTextChange = (event: React.ChangeEvent<HTMLTextAreaElement>): void => {
    setAction(event.target.value);
  };

  const onEditClick = (): void => {
    dispatch(incrementNumOfEdits());
    setEditable(true);
  };

  const onDoneClick = (): void => {
    setEditable(false);
    dispatch(setNodeData({ nodeId: props.nodeId, data: action }));
    dispatch(decrementNumOfEdits());
  };


  /****************************************************************
  **** Return.
  ****************************************************************/

  if (editable) {
    return (
      <Group noWrap={true} align="center">
        <Textarea
          size="md"
          autosize
          minRows={2}
          maxRows={6}
          value={action}
          onChange={handleTextChange}
          className={classes.text_input}
        />

        <ActionIcon onClick={onDoneClick}>
          <IconCheckbox color="blue" />
        </ActionIcon>
      </Group>
    );
  }

  return (
    <Group noWrap={true} align="center">
      <Text className={classes.action}>
        {action}
      </Text>

      <ActionIcon onClick={onEditClick} disabled={editIsDisabled}>
        <IconEdit />
      </ActionIcon>
    </Group>
  );
};

export default ActionSection;
