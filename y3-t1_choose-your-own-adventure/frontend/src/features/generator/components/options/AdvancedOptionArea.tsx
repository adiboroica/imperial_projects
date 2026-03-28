import { Textarea } from "@mantine/core";
import classes from './AdvancedOptionArea.module.css';

type AdvancedOptionAreaProps = {
  name: string;
  value: string;
  onChange: React.ChangeEventHandler<HTMLTextAreaElement>;
}

const AdvancedOptionArea = (props: AdvancedOptionAreaProps) => {

  return (
    <>
      <p>{props.name}: </p>
      <Textarea
        className={classes.textarea}
        autosize minRows={2}
        value={props.value}
        onChange={props.onChange}
      />
    </>
  );
}

export default AdvancedOptionArea;
