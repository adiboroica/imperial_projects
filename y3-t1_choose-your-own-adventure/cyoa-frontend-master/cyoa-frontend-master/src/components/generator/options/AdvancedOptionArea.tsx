import { createStyles, Textarea } from "@mantine/core";

const useStyles = createStyles((theme) => ({
  textarea: {
    paddingBottom: "1em"
  }
}));

type AdvancedOptionAreaProps = {
  name: string;
  value: string;
  onChange: React.ChangeEventHandler<HTMLTextAreaElement>;
}

const AdvancedOptionArea = (props: AdvancedOptionAreaProps) => {

  const { classes } = useStyles();

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
