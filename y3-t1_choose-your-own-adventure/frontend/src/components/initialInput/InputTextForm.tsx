import { Textarea } from '@mantine/core';
import { useState } from "react";
import { initStory, setGraph } from '../../store/features/storySlice';
import { useAppDispatch } from '../../store/hooks';
import { makeNarrativeNode } from '../../utils/graph/graphUtils';
import { Graph, NarrativeNode } from '../../utils/graph/types';
import GenerateButton from './GenerateButton';
import './InputTextForm.css';


const InitialInputTextForm = () => {
  const dispatch = useAppDispatch();

  const [text, setText] = useState("");


  const handleInputText = (event: React.ChangeEvent<HTMLTextAreaElement>): void => {
    setText(event.target.value);
  };

  const handleGenerateText = (text: string) => {
    dispatch(initStory());

    const root: NarrativeNode = makeNarrativeNode({
      nodeId: 0,
      data: text,
      childrenIds: [],
      isEnding: false,
    });

    const graph: Graph = {
      nodeLookup: {
        0: root
      },
    };

    dispatch(setGraph(graph));
  };


  const exampleText = "You are a commoner living in the large kingdom of Garion. Your kingdom has been in bitter war with the neighboring kingdom, Liore, for the past year. You dream of doing something great and going on an adventure. You walk around town and see warning posters about the dangers of the dark forest at the edge of town. You go to the market and see military representatives signing people up for the army.";


  return (
    <div className="w-full text-center">
      <div className="text-start">
        <Textarea
          placeholder="Input your starting paragraph here."
          description={`Example: ${exampleText}`}
          onChange={handleInputText}
          id="custom-textarea"
        />
      </div>

      <GenerateButton onClick={() => handleGenerateText(text)} />
    </div>
  );
};

export default InitialInputTextForm;
