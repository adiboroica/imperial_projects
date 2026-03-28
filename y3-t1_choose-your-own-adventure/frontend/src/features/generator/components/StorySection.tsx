import { StoryNode } from "../../../utils/graph/types";
import {
  Text,
  Title,
  Stack,
  Box,
  Divider,
  Space,
} from '@mantine/core';
import NarrativeSection from "./section/NarrativeSection";
import ActionSection from "./section/ActionSection";
import classes from './StorySection.module.css';


export interface StorySectionProps extends StoryNode { };

function StorySection(props: StorySectionProps) {

  const ListOfActions = () => {
    return (
      <>
        <Title order={4} fw={600}>
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
      <Stack gap="sm" className={classes.stack}>
        <Text>
          <Title order={2} className={classes.paragraphTitle}>
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
