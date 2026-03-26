import {
  Container, createStyles, ScrollArea, Slider,
  Space, Tabs, Text
} from '@mantine/core';
import { IconPlus, IconSettings } from '@tabler/icons';
import { memo } from 'react';
import { setTemperature } from '../../../store/features/storySlice';
import { useAppDispatch, useAppSelector } from '../../../store/hooks';
import { isNarrative } from '../../../utils/graph/graphUtils';
import { ActionNode, NarrativeNode, NodeData, NodeType } from '../../../utils/graph/types';
import ActionAdvancedOptions from './ActionAdvancedOptions';
import ActionOptions from './ActionOptions';
import NarrativeOptions from './NarrativeOptions';

const useStyles = createStyles((theme) => ({

  slider: {
    paddingBottom: "2em",
    marginLeft: "8px",
    marginRight: "8px",
  },

  textarea: {
    paddingBottom: "1em"
  },

  text: {
    wordBreak: "break-word",
    overflowWrap: "break-word",
    hyphens: "auto",
  },
}));

function nodeDataToString(data: NodeData) {
  if (data.type === NodeType.Action)
    return "Option";

  const narrativeData = data as NarrativeNode;
  if (narrativeData.isEnding)
    return "Ending";
  return "Paragraph";
}

type NodeOptionsProps = {
  nodeData: NodeData,
};

const NodeOptions = (props: NodeOptionsProps) => {

  const temperature = useAppSelector((state) => state.story.temperature);

  const dispatch = useAppDispatch();

  const { classes } = useStyles();

  return (
    <Container px={0}>
      <Tabs defaultValue="actions">
        <Tabs.List>
          <Tabs.Tab value="actions" icon={<IconPlus size={14} />}>Actions</Tabs.Tab>
          <Tabs.Tab value="settings" icon={<IconSettings size={14} />}>Settings</Tabs.Tab>
        </Tabs.List>

        <Tabs.Panel value="actions" pt="xs">
          <ScrollArea.Autosize maxHeight={310}>
            <b>Selected: {nodeDataToString(props.nodeData)}</b>
            <Text lineClamp={3} className={classes.text}>
              {props.nodeData.data}
            </Text>

            <Space h="md" />

            {
              isNarrative(props.nodeData) ? (
                <NarrativeOptions narrativeNode={props.nodeData as NarrativeNode} />
              ) : (
                <ActionOptions actionNode={props.nodeData as ActionNode} />
              )
            }

            <Space h="sm"></Space>
          </ScrollArea.Autosize>

        </Tabs.Panel>

        <Tabs.Panel value="settings" pt="xs">
          <ScrollArea.Autosize maxHeight={310}>
            <b>Advanced options: </b>

            {
              !isNarrative(props.nodeData) && <ActionAdvancedOptions />
            }

            <p>Creativity: </p>
            <Slider
              className={classes.slider}
              value={temperature}
              onChange={(t) => dispatch(setTemperature(t))}
              min={0}
              max={1}
              step={0.2}
              label={(value) => value.toFixed(1)}
              marks={[
                { value: 0, label: "0" },
                { value: 0.2 },
                { value: 0.4 },
                { value: 0.6 },
                { value: 0.8 },
                { value: 1, label: "1" },
              ]}
            />
          </ScrollArea.Autosize>
        </Tabs.Panel>
      </Tabs>
    </Container>
  );
};

export default memo(NodeOptions);
