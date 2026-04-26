/**
 * Skeleton shown while the initial story is being generated.
 */

import { Center, Loader, Paper, Stack, Text } from "@mantine/core";

const LoadingInitialParagraph = () => {
  return (
    <Paper withBorder p="xl" radius="md">
      <Center>
        <Stack align="center" gap="md">
          <Loader />
          <Text c="dimmed">Generating your story…</Text>
        </Stack>
      </Center>
    </Paper>
  );
};

export default LoadingInitialParagraph;
