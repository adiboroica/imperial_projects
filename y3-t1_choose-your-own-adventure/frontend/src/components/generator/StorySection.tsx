import { StoryNode } from "../../utils/graph/types";
import {
  Text,
  createStyles,
  Title,
  Stack,
  Box,
  Divider,
  Space,
} from '@mantine/core';
import NarrativeSection from "./section/NarrativeSection";
import ActionSection from "./section/ActionSection";


const useStyles = createStyles((theme) => ({

  sectionArea: {
    backgroundColor: theme.white,
    borderRadius: 5,
    marginTop: 8,
    marginBottom: 8,
  },

  stack: {
    padding: 28
  },

  paragraph_title: {
    color: theme.colors.black,
  },

  actionsList: {
    marginLeft: 32,
  },

  actionsListItem: {
    display: "list-item",
  },
}));


export interface StorySectionProps extends StoryNode { };

function StorySection(props: StorySectionProps) {
  const { classes } = useStyles();

  const ListOfActions = () => {
    return (
      <>
        <Title order={4} weight={600}>
          Options:
        </Title>
        <div className={classes.actionsList}>
          {
            props.actions!.map((action, index) => {
              return (
                <div key={index} className={classes.actionsListItem}>
                  <ActionSection action={action} nodeId={props.childrenIds[index]} />
                  <Space h="sm" />
                </div>
              )
            })
          }
        </div>
      </>
    );
  }

  return (
    <Box className={classes.sectionArea}>
      <Stack spacing="sm" className={classes.stack}>
        <Text>
          <Title order={2} className={classes.paragraph_title}>
            Section {props.sectionId}
          </Title>
          <Text fz="sm" c="dimmed" fs="italic">Section paragraph and list of actions. </Text>
        </Text>
        <NarrativeSection {...props} />

        {props.isEnding
          ?
          <></>
          :
          <>
            <Divider my="sm" variant="dashed" />
            <ListOfActions />
          </>
        }
      </Stack>
    </Box>
  );
};

export default StorySection;
