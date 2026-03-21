import {
  Center,
  Group,
  Loader,
  Text
} from '@mantine/core';


function LoadingInitialParagraph() {
  return (
    <Center style={{ height: 300 }}>
      <Group>
        <Text fw={700} fz="lg" fs="italic">
          Generating the initial paragraph and options...
        </Text>
        <Loader />
      </Group>
    </Center>
  );
}

export default LoadingInitialParagraph;
