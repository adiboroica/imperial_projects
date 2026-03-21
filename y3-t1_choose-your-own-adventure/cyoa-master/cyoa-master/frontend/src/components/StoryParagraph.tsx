import { useState } from 'react';
import { Accordion, Button } from "react-bootstrap";
import { useAccordionButton } from 'react-bootstrap/AccordionButton';

export interface StoryParagraphNodeData {
  nodeId: number,
  parentId: number | null,
  paragraph: string,
  actions: string[],
  childrenIds: number[],
}

interface ChildParagraphProps {
  key: number,
  index: number,
  id: number,
  action: string,
  onGenerateAction: () => void,
}

export interface StoryAccordionItemProps extends StoryParagraphNodeData {
  onGenerateParagraph: () => void,
  onGenerateAction: () => void,
}

interface ToggleButtonProps {
  // TODO: Change 'any'.
  children: any,
  eventKey: string,
}

function ToggleButton(props: ToggleButtonProps) {
  const onClick = useAccordionButton(
    props.eventKey,
    () => { },
  );

  return (
    <Button
      className="submit-button"
      variant="light"
      onClick={onClick}
    >
      {props.children}
    </Button>
  );
}

const ChildParagraph = (props: ChildParagraphProps) => {
  return (
    <li>
      <StoryParagraph text={props.action} editable={false} />
      <Button className="submit-button" variant="light" onClick={props.onGenerateAction}>
        {props.id}
        Generate
      </Button>
      <ToggleButton eventKey={`${props.id}`}>
        Go to child
        {props.id}
      </ToggleButton>
    </li>
  )
}

interface StoryParagraphProps {
  text: string,
  editable: boolean,
}

const StoryParagraph = (props: StoryParagraphProps) => {
  const [text, setText] = useState(props.text);
  const [editable, changeEditable] = useState(props.editable);

  const handleTextChange = (event: React.ChangeEvent<HTMLTextAreaElement>): void => {
    setText(event.target.value);
  };

  const handleEdit = (): void => {
    changeEditable(!editable);
  };

  return (
    <div>
      {
        editable
          ? <textarea value={text} onChange={handleTextChange} />
          : <p>{text}</p>
      }
      <Button variant="light" onClick={handleEdit}>
        Edit
      </Button>
    </div>
  )

}

const StoryAccordionItem = (props: StoryAccordionItemProps) => {
  const generateButton =
    <Button className="submit-button" variant="light" onClick={props.onGenerateParagraph}>
      Generate
    </Button>;

  const parrentButton =
    <ToggleButton eventKey={`${props.parentId}`}>
      Go to parent
      {props.parentId}
    </ToggleButton>

  return (
    <Accordion.Item eventKey={`${props.nodeId}`} id={`${props.nodeId}`}>
      <Accordion.Header>
        Section {props.nodeId}
      </Accordion.Header>

      <Accordion.Body>
        <StoryParagraph text={props.paragraph} editable={false} />

        {generateButton}

        <>{props.parentId != null && parrentButton}</>

        <ul>
          {
            props.actions.map((action, i) => {
              return (
                <ChildParagraph
                  key={i}
                  index={i}
                  id={props.childrenIds[i]}
                  action={action}
                  onGenerateAction={props.onGenerateAction}
                />
              );
            })
          }
        </ul>
      </Accordion.Body>
    </Accordion.Item>
  );
};

export default StoryAccordionItem;
