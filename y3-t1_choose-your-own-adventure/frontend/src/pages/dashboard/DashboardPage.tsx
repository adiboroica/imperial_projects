/**
 * Dashboard — list of the user's stories.
 */

import {
  Button,
  Center,
  Container,
  Group,
  Skeleton,
  Stack,
  Text,
  Title,
} from "@mantine/core";
import { useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";

import { useAppDispatch, useAppSelector } from "../../store/hooks";
import {
  GENERATOR_PAGE,
  SETUP_PAGE,
} from "../../utils/routes";
import {
  deleteStory,
  listStories,
  selectDashboardLoading,
  selectDashboardStories,
} from "./slices/dashboard";
import StoryListItem from "./components/StoryListItem";

const DashboardPage = () => {
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const stories = useAppSelector(selectDashboardStories);
  const loading = useAppSelector(selectDashboardLoading);

  useEffect(() => {
    dispatch(listStories());
  }, [dispatch]);

  const onOpen = (id: string) => navigate(`${GENERATOR_PAGE}${id}`);
  const onDelete = (id: string) => dispatch(deleteStory(id));

  return (
    <Container size="md" py="xl">
      <Group justify="space-between" mb="lg">
        <Title order={2}>Your stories</Title>
        <Button component={Link} to={SETUP_PAGE}>
          New story
        </Button>
      </Group>

      {loading && (
        <Stack gap="sm">
          <Skeleton height={80} />
          <Skeleton height={80} />
          <Skeleton height={80} />
        </Stack>
      )}

      {!loading && stories.length === 0 && (
        <Center py="xl">
          <Stack align="center">
            <Text c="dimmed">No stories yet.</Text>
            <Button component={Link} to={SETUP_PAGE}>
              Start your first story
            </Button>
          </Stack>
        </Center>
      )}

      {!loading && stories.length > 0 && (
        <Stack gap="sm">
          {stories.map((story) => (
            <StoryListItem
              key={story.id}
              story={story}
              onOpen={onOpen}
              onDelete={onDelete}
            />
          ))}
        </Stack>
      )}
    </Container>
  );
};

export default DashboardPage;
