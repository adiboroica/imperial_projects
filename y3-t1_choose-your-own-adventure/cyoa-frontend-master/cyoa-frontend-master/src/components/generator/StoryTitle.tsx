import {
  ActionIcon, Button, Center, Container, createStyles,
  Divider,
  Flex,
  Group, Text,
  TextInput,
  Title
} from '@mantine/core';
import { IconEdit } from '@tabler/icons';
import { useEffect, useMemo, useState } from 'react';
import { saveName, selectStoryGraph, selectStoryTitle, setName } from '../../store/features/storySlice';
import { useAppDispatch, useAppSelector } from '../../store/hooks';
import { getStoryNodes } from '../../utils/graph/storyUtils';
import DownloadButton from './buttons/DownloadButton';
import SaveButton from './buttons/SaveButton';


const useStyles = createStyles((theme) => ({

  titleBox: {
    backgroundColor: theme.colors.gray[0],
    padding: theme.spacing.md,
    paddingLeft: 20,
    paddingRight: 20,
    borderRadius: theme.radius.sm,
    width: "100%",
  },
  title: {
    width: "100%",
    alignItems: 'left',
  },

  leftBox: {
    width: "72%",
  },
  rightBox: {
    width: "24%",
  },
}));


function StoryTitle() {
  const { classes } = useStyles();

  const storyGraph = useAppSelector(selectStoryGraph);

  const story = useMemo(() => {
    return getStoryNodes(storyGraph, false);
  }, [storyGraph]);


  return (
    <Container size="xl" className={classes.titleBox}>
      <Group noWrap={true}>
        <Flex className={classes.leftBox}
          align="flex-start"
          direction="column"
          wrap="nowrap"
          gap="md"
        >
          <Text fz="md" td="underline" fs="italic" fw={500}>Story Title:</Text>

          <EditableTitle />
        </Flex>

        <Divider orientation='vertical' variant='dashed' />

        <Flex className={classes.rightBox}
          align="center"
          direction="column"
          wrap="nowrap"
          gap="md"
        >
          <SaveButton />

          <DownloadButton story={story} />
        </Flex>
      </Group>
    </Container>
  );
}

export default StoryTitle;


const EditableTitle = () => {
  const dispatch = useAppDispatch();
  const storyTitle = useAppSelector(selectStoryTitle);

  const [editable, setEditable] = useState(false);
  const [title, setTitle] = useState(storyTitle);


  /****************************************************************
  **** Effects.
  ****************************************************************/

  useEffect(() => {
    setTitle(storyTitle);
  }, [storyTitle]);


  /****************************************************************
  **** Functions.
  ****************************************************************/

  const handleTextChange = (event: React.ChangeEvent<HTMLInputElement>): void => {
    setTitle(event.target.value);
  };

  const onIconClick = (): void => {
    setEditable(true);
  }

  const onSaveClick = (): void => {
    setEditable(false);
    dispatch(setName(title));
    dispatch(saveName());
  }


  /****************************************************************
  **** Components.
  ****************************************************************/

  const TitleDisplay = () => {
    if (title) {
      return (
        <Title order={2} sx={{ textOverflow: 'ellipsis', overflow: 'hidden' }} > {title} </Title>
      );
    }

    return (
      <Text fz="xl" fw={700} fs="italic" c="dimmed">
        Enter your story title
      </Text>
    );
  }


  /****************************************************************
  **** Return.
  ****************************************************************/

  if (editable) {
    return (
      <Group noWrap={true} position="apart" style={{ width: "100%" }}>
        <TextInput value={title} onChange={handleTextChange} disabled={!editable} size="lg" />

        <Button onClick={onSaveClick}>
          Save Title
        </Button>
      </Group>
    );
  }

  return (
    <Group noWrap={true} position="apart" style={{ width: "100%" }}>
      <TitleDisplay />

      <ActionIcon variant="filled" size="md" color="blue" onClick={onIconClick}>
        <IconEdit size={20} />
      </ActionIcon>
    </Group>
  );
}
