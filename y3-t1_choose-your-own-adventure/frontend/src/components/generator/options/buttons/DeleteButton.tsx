import { Button, createStyles, Popover } from "@mantine/core";
import { deleteChildNodes, deleteNode } from "../../../../store/features/storySlice";
import { useAppDispatch } from "../../../../store/hooks";


interface DeleteButtonProps {
  nodeId: number,
  disabled: boolean,
  onlyChildren: boolean,
};

const useStyles = createStyles((theme) => ({
  deleteButton: {
    textAlign: "center"
  },

}));


const DeleteButton = (props: DeleteButtonProps) => {

  const { classes } = useStyles();
  const dispatch = useAppDispatch();

  const text = props.onlyChildren ? "Delete All Actions" : "Delete";

  const onClick = props.onlyChildren
    ? () => dispatch(deleteChildNodes(props.nodeId))
    : () => dispatch(deleteNode(props.nodeId))

  return (
    <Popover position="bottom" withArrow shadow="md">
      <Popover.Target>
        <Button disabled={props.disabled} variant="outline" color={"red"}>{text}</Button>
      </Popover.Target>
      <Popover.Dropdown>
        <Button variant="subtle" onClick={onClick} className={classes.deleteButton}>
          Confirm:<br />{text}
        </Button>
      </Popover.Dropdown>
    </Popover>
  );
}


export default DeleteButton;