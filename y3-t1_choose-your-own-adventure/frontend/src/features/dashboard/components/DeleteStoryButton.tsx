import { Button, Group, Modal, Text } from "@mantine/core";
import { IconTrash } from "@tabler/icons-react";
import { useState } from "react";
import { deleteStory } from "../../../store/features/accountSlice";
import { useAppDispatch } from "../../../store/hooks";


interface DeleteStoryButtonProps {
  storyId: string,
}

function DeleteStoryButton(props: DeleteStoryButtonProps) {

  const dispatch = useAppDispatch();

  const [opened, setOpened] = useState(false);


  const onModalClick = (event: React.MouseEvent) => {
    event.stopPropagation();
  }

  const onDeleteStoryButtonClick = (event: React.MouseEvent) => {
    event.stopPropagation();
    setOpened(true);
  }

  const onYesClick = () => {
    dispatch(deleteStory(props.storyId));
  }

  const onNoClick = () => {
    setOpened(false);
  }


  const DeleteStoryModal = () => {
    return (
      <Modal
        centered
        opened={opened}
        onClose={() => setOpened(false)}
        title={
          <Text fw={700}>
            Are you sure that you want to delete this story?
          </Text>
        }
        withCloseButton={false}
        closeOnClickOutside={false}
        closeOnEscape={false}
        onClick={onModalClick}
      >
        <Group justify="space-between">
          <Button color="red" onClick={onYesClick}>
            Yes
          </Button>

          <Button color="gray" onClick={onNoClick}>
            No
          </Button>
        </Group>
      </Modal>
    );
  }

  const DeleteStoryBtn = () => {
    return (
      <Button
        variant="light"
        color="red"
        rightSection={<IconTrash />}
        size="xs"
        onClick={onDeleteStoryButtonClick}
      >
        Delete Story
      </Button>
    );
  }


  return (
    <>
      <DeleteStoryModal />
      <DeleteStoryBtn />
    </>
  )

}

export default DeleteStoryButton;
