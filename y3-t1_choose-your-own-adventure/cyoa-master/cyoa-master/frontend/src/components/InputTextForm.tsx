import { Button } from "react-bootstrap";
import { useAppSelector, useAppDispatch } from "../app/hooks";
import { editText, generateText } from "../features/text/inputTextSlice";

interface InputTextFormProps {
  exampleText: string,
}

const InputTextForm = (props: InputTextFormProps) => {
  const text = useAppSelector((state) => state.inputText.value);
  const dispatch = useAppDispatch();

  const handleInputText = (e: React.ChangeEvent<HTMLTextAreaElement>): void => {
    dispatch(editText(e.currentTarget.value));
  };

  const handleGenerate = (): void => {
    dispatch(generateText());
  };

  return (
    <div className="input-form">
      <p className="example-text">
        <b>Example</b>
        <br />
        {props.exampleText}
      </p>
      <textarea
        className="input-text"
        value={text}
        placeholder="Input your starting paragraph here"
        onChange={handleInputText}
      />
      <Button className="submit-button" variant="light"
        onClick={handleGenerate}>
        Generate
      </Button>
    </div>
  );
};

export default InputTextForm;
