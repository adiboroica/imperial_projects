/**
 * Story list row — title, preview, action count, open + delete.
 */

import { Button, Group, Paper, Stack, Text } from "@mantine/core";

import type { StoryListItem as StoryListItemType } from "../../../types";
import DeleteStoryButton from "./DeleteStoryButton";

type Props = {
  story: StoryListItemType;
  onOpen: (id: string) => void;
  onDelete: (id: string) => void;
};

const StoryListItem = ({ story, onOpen, onDelete }: Props) => {
  return (
    <Paper withBorder p="md" radius="md">
      <Group justify="space-between" align="center">
        <Stack gap={4} style={{ flex: 1, minWidth: 0 }}>
          <Text fw={600} truncate>
            {story.name}
          </Text>
          <Text size="sm" c="dimmed" lineClamp={2}>
            {story.firstParagraph}
          </Text>
          <Text size="xs" c="dimmed">
            {story.totalSections} section{story.totalSections === 1 ? "" : "s"}
          </Text>
        </Stack>
        <Group>
          <Button variant="light" onClick={() => onOpen(story.id)}>
            Open
          </Button>
          <DeleteStoryButton onConfirm={() => onDelete(story.id)} />
        </Group>
      </Group>
    </Paper>
  );
};

export default StoryListItem;
