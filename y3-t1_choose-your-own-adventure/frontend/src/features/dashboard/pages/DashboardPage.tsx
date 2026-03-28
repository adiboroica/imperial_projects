import {
  Button,
  Center,
  Container,
  Divider,
  Group,
  Loader,
  Stack,
  Text, ThemeIcon, Title
} from '@mantine/core';
import { IconInfoCircle, IconPlus } from '@tabler/icons-react';
import { useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import StoryListItem from '../components/StoryListItem';
import {
  loadStories, selectStories
} from '../../../store/features/accountSlice';
import { useAppDispatch, useAppSelector } from '../../../store/hooks';
import { ACCOUNT_PAGE, INITIAL_INPUT_PAGE } from '../../../utils/routes';
import classes from './DashboardPage.module.css';


function DashboardView() {
  const navigate = useNavigate();

  const dispatch = useAppDispatch();
  const stories = useAppSelector(selectStories);

  const loaded = stories !== undefined;


  useEffect(() => {
    dispatch(loadStories());
  }, [dispatch]);


  const onCreateNewStoryButtonClick = () => {
    navigate(INITIAL_INPUT_PAGE);
  };


  const StoryList = () => {

    if (!loaded) {
      return (
        <Center style={{ height: 200 }}>
          <Loader />
        </Center>
      );
    }

    return (
      <Stack gap="sm">
        {
          stories?.map(story =>
          (
            <StoryListItem
              storyId={story.storyId}
              key={story.storyId}
              name={story.name}
              firstParagraph={story.firstParagraph}
              totalSections={story.totalSections}
            />
          ))
        }
      </Stack>
    );
  }



  return (
    <Container className="wrapper">
      <Group justify="space-between">
        <Title order={1} c="black">Welcome back!</Title>
        <Button
          className={classes.createNewStoryButton}
          variant="filled"
          leftSection={<IconPlus />}
          onClick={onCreateNewStoryButtonClick}
        >
          Create New Story
        </Button>
      </Group>
      <Divider my="sm" />
      <Group
        gap="xs"

        ml={15}
        mb={15}>
        <ThemeIcon
          radius="lg"
          variant="light">
          <IconInfoCircle />
        </ThemeIcon>
        <Text
          fz="xs"
          fs="italic"
          c="dark.04"
          fw={600}
        >
          <Text>We use AI to generate your stories.</Text>
          For faster story generation, you can supply your own OpenAI API key under
          <Link to={ACCOUNT_PAGE} style={{ textDecoration: 'underline', color: '#467BE1' }}> Account Settings</Link>.
        </Text>
      </Group>
      <StoryList />
    </Container>
  );
}

export default DashboardView;
