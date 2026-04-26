/**
 * Generator — interactive story editor.
 *
 * Mounts, fetches the story, renders a graph canvas + side panel + page-level
 * controls. The canvas uses a simple list view; replace with `GraphCanvas`
 * (ReactFlow) when richer interaction is needed.
 */

import {
  Alert,
  Center,
  Container,
  Grid,
  Loader,
  Paper,
  Stack,
  Title,
} from "@mantine/core";
import { useEffect } from "react";
import { useParams } from "react-router-dom";

import { useAppDispatch, useAppSelector } from "../../store/hooks";
import GraphCanvas from "./components/graph/GraphCanvas";
import GraphToolbar from "./components/graph/GraphToolbar";
import LoadingInitialParagraph from "./components/LoadingInitialParagraph";
import NodeOptions from "./components/options/NodeOptions";
import SaveButton from "./components/SaveButton";
import DownloadButton from "./components/DownloadButton";
import StoryTitle from "./components/StoryTitle";
import {
  getStory,
  selectGraphIsEmpty,
  selectGraphLoaded,
  selectLoadError,
  selectStoryName,
} from "./slices/graph";
import { selectIsLoading } from "./slices/loading";

const GeneratorPage = () => {
  const dispatch = useAppDispatch();
  const { storyId = "" } = useParams<{ storyId: string }>();
  const graphLoaded = useAppSelector(selectGraphLoaded);
  const graphEmpty = useAppSelector(selectGraphIsEmpty);
  const isLoading = useAppSelector(selectIsLoading);
  const storyName = useAppSelector(selectStoryName);
  const loadError = useAppSelector(selectLoadError);

  useEffect(() => {
    if (storyId) dispatch(getStory(storyId));
  }, [dispatch, storyId]);

  if (!graphLoaded) {
    return (
      <Center mih="60vh">
        <Loader />
      </Center>
    );
  }

  if (loadError) {
    return (
      <Container size="md" py="xl">
        <Alert color="red" title="Could not load story">
          {loadError}
        </Alert>
      </Container>
    );
  }

  return (
    <Container size="xl" py="md">
      <Stack gap="md">
        <Paper withBorder p="md" radius="md">
          <Stack gap="xs">
            <StoryTitle />
            <GraphToolbar storyId={storyId} />
          </Stack>
        </Paper>

        {graphEmpty && isLoading ? (
          <LoadingInitialParagraph />
        ) : (
          <Grid gutter="md">
            <Grid.Col span={{ base: 12, md: 8 }}>
              <Paper withBorder p="md" radius="md" mih={500}>
                <Title order={4} mb="sm">
                  {storyName || "Untitled"}
                </Title>
                <GraphCanvas />
              </Paper>
            </Grid.Col>
            <Grid.Col span={{ base: 12, md: 4 }}>
              <Paper withBorder p="md" radius="md" mih={500}>
                <NodeOptions />
              </Paper>
            </Grid.Col>
          </Grid>
        )}

        <Paper withBorder p="md" radius="md">
          <Stack gap="xs">
            <SaveButton />
            <DownloadButton storyId={storyId} />
          </Stack>
        </Paper>
      </Stack>
    </Container>
  );
};

export default GeneratorPage;
