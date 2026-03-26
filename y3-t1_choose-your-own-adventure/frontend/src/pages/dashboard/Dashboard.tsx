import {
  Button,
  Center,
  Container,
  createStyles,
  Divider,
  Group,
  Loader,
  Stack,
  Text, ThemeIcon, Title
} from '@mantine/core';
import { IconInfoCircle, IconPlus } from '@tabler/icons';
import { useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import StoryListItem from '../../components/dashboard/StoryListItem';
import {
  loadStories, selectStories
} from '../../store/features/accountSlice';
import { useAppDispatch, useAppSelector } from '../../store/hooks';
import { ACCOUNT_PAGE, INITIAL_INPUT_PAGE } from '../../utils/pages';

const useStyles = createStyles((theme) => ({

  createNewStoryButton: {
    float: 'right',
  },
}));


function DashboardView() {
  const { classes } = useStyles();
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
      <Stack spacing="sm">
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
      <Group position="apart">
        <Title order={1} span={true} color="black">Welcome back!</Title>
        <Button
          className={classes.createNewStoryButton}
          variant="filled"
          leftIcon={<IconPlus />}
          onClick={onCreateNewStoryButtonClick}
        >
          Create New Story
        </Button>
      </Group>
      <Divider my="sm" />
      <Group
        spacing="xs"

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
          weight={600}
        >
          <Text>We use GPT3 to generate your stories.</Text>
          For faster story generation, you can supply your own API key for GPT3 under
          <Link to={ACCOUNT_PAGE} style={{ textDecoration: 'underline', color: '#467BE1' }}> Account Settings</Link>.
        </Text>
      </Group>
      <StoryList />
    </Container >
  );
}

export default DashboardView;
