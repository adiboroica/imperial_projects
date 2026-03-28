import { useAppDispatch } from "../../../store/hooks";
import { saveGraph } from "../../../store/features/storySlice";
import { Button } from "@mantine/core";
import classes from './SaveButton.module.css';


function SaveButton() {

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
