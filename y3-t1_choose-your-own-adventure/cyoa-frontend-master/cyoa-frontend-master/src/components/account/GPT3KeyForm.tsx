import {
  ActionIcon,
  Button,
  Group,
  Textarea,
} from "@mantine/core";
import { IconEdit } from "@tabler/icons";
import { useState } from "react";
import { updateApiKey } from "../../store/features/accountSlice";
import { useAppDispatch } from "../../store/hooks";


interface GPT3KeyFormProps {
  apiKey: string,
}


function GPT3KeyForm(props: GPT3KeyFormProps) {

  const dispatch = useAppDispatch();

  const [key, setKey] = useState(props.apiKey);
  const [editable, setEditable] = useState(false);


  const handleTextChange = (event: React.ChangeEvent<HTMLTextAreaElement>): void => {
    setKey(event.target.value);
  };

  const onIconClick = (): void => {
    setEditable(true);
  }

  const onApiKeyChange = () => {
    setEditable(false);
    dispatch(updateApiKey(key))
  }

  return (
    <Group align="center" position="apart">
      <Textarea
        label={"GPT3 Key"}
        value={key}
        mb="lg"
        disabled={!editable}
        onChange={handleTextChange}
        autosize
      />
      {editable
        ?
        <Button onClick={onApiKeyChange}>
          Change API Key
        </Button>
        :
        <ActionIcon variant="filled" size="md" color="blue" onClick={onIconClick}>
          <IconEdit size={20} />
        </ActionIcon>
      }
    </Group>
  );
}

export default GPT3KeyForm;
