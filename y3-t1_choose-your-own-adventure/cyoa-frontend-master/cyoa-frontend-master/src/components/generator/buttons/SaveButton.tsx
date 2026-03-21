import { useAppDispatch } from "../../../store/hooks";
import { saveGraph } from "../../../store/features/storySlice";
import { Button, createStyles } from "@mantine/core";


const useStyles = createStyles((theme) => ({

  saveButton: {
    width: "40%",
  },
}));

function SaveButton() {
  const { classes } = useStyles();

  const dispatch = useAppDispatch();

  const onSaveClick = () => {
    dispatch(saveGraph());
  }

  return (
    <Button
      className={classes.saveButton}
      variant="gradient"
      gradient={{ from: 'teal', to: 'blue', deg: 60 }}
      onClick={onSaveClick}
    >
      Save
    </Button>
  );
}

export default SaveButton;
