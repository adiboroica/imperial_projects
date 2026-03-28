import { Badge, Card, Container, Group, Text } from '@mantine/core';
import { useNavigate } from 'react-router-dom';
import { GENERATOR_PAGE } from '../../../utils/routes';
import DeleteStoryButton from './DeleteStoryButton';


interface StoryListItemProps {
  storyId: string,
  name: string,
  firstParagraph: string,
  totalSections: number,
}

function StoryListItem(props: StoryListItemProps) {
  const navigate = useNavigate();


  const navigateToStory = () => {
    navigate(GENERATOR_PAGE + props.storyId);
  }


  return (
    <Card
      onClick={navigateToStory}
      shadow="md"
      radius="md"
      withBorder
    >
      <Group justify="space-between">
        <Text
          mt="xs"
          mb="xs"
          fz="xl"
          fw={600}
          c="dark.7"
        >
          {props.name}
        </Text>
        <DeleteStoryButton storyId={props.storyId} />
      </Group>

      <Container px={0}>
        <Text size="sm" c="dimmed" mb="xs" lineClamp={3}>
          {props.firstParagraph}
        </Text>

        <Badge color={props.totalSections === 0 ? "red" : "indigo"} variant="outline">
          Total Sections: {props.totalSections}
        </Badge>
      </Container>
    </Card>
  );
}

export default StoryListItem;
