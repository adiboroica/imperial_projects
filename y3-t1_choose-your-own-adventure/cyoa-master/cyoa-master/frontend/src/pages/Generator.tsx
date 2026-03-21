import '../style/base.css';
import { Accordion, Container } from 'react-bootstrap';
import InputTextForm from '../components/InputTextForm';
import { NodeData } from '../graph/types';
import StoryAccordionItem, { StoryParagraphNodeData } from '../components/StoryParagraph';
import useWebSocket from 'react-use-websocket';
import { useEffect } from 'react';
import { useAppDispatch } from '../app/hooks';
import { setNodeData } from '../features/text/storySlice';
import { Graph } from '../graph/types'
import { graphToNodeData } from '../graph/graphUtils';

interface GeneratorViewProps {
  exampleText: string,
  storyGraph: Graph,
}

interface SocketResponse {
  nodes: NodeData[],
}

const GeneratorView = (props: GeneratorViewProps) => {

  const { sendMessage, lastMessage } = useWebSocket("ws://localhost:8000/ws/");

  const sendExpandMessage = (nodeToExpand: number) => {
    sendMessage(JSON.stringify({type: "expandNode", data: {nodeToExpand, nodes: graphToNodeData(props.storyGraph)}}))
  }

  const dispatch = useAppDispatch();

  useEffect(() => {
    if (lastMessage !== null) {
      const resp = JSON.parse(lastMessage?.data) as SocketResponse
      dispatch(setNodeData(resp.nodes));
    }
  }, [lastMessage, dispatch])

  const buildStoryFromGraph = (): StoryParagraphNodeData[] => {
    const record = props.storyGraph.nodeLookup;

    const story: StoryParagraphNodeData[] = [];
    const queue = [record[0]];
    let currNode: NodeData;

    while (queue.length !== 0) {
      // TODO This is yikes cause shift is O(n), refactor this
      currNode = queue.shift()!;
      const actions: string[] = [];

      // Note: For loops are much faster than functional programming in Node.js
      for (const child of currNode.childrenIds) {
        queue.push(record[child]);
        actions.push(record[child].action!);
      }

      story.push({
        paragraph: currNode.paragraph,
        actions,
        nodeId: currNode.nodeId,
        parentId: currNode.parentId,
        childrenIds: currNode.childrenIds,
      });
    }

    return story;
  }

  return (
    <Container id="generator-section" className="wrapper">
      <header id="generator-title">
        <h1>Enter a paragraph</h1>
      </header>
      <InputTextForm exampleText={props.exampleText} />
      {
        props.storyGraph.nodeLookup[0] &&
        (
          <Container id="story-section">
            <Accordion defaultActiveKey="0">
            {
              buildStoryFromGraph().map((section, i) => {
                return (
                  <StoryAccordionItem
                    key={i}
                    paragraph={section.paragraph}
                    actions={section.actions}
                    nodeId={section.nodeId}
                    parentId={section.parentId}
                    childrenIds={section.childrenIds}
                    onGenerateParagraph={() => sendExpandMessage(section.nodeId)}
                    onGenerateAction={() => sendExpandMessage(section.childrenIds[i])}
                  />
                );
              })
            }
            </Accordion>
          </Container>
        )
      }
    </Container>
  );
};

export default GeneratorView;
