import { Button, TextInput, Table, ActionIcon, Group, Container, Stack, Center } from '@mantine/core';
import './AttributeTable.css';
import { IconTrash, IconNewSection } from '@tabler/icons';
import { useAppDispatch, useAppSelector } from '../../store/hooks';
import { addEntry, removeEntry, selectInitialInputValues, setAttribute, setContent } from '../../store/features/initialInputSlice';


function AttributeTable() {

  const dispatch = useAppDispatch();
  const initialInputValues = useAppSelector(selectInitialInputValues);


  const onAttributeChange = (position: number, data: string) => {
    dispatch(setAttribute({ position, data }));
  }

  const onContentChange = (position: number, data: string) => {
    dispatch(setContent({ position, data }));
  }

  const onRemoveClick = (position: number) => {
    dispatch(removeEntry({ position }));
  }

  const onAddAttributeClick = () => {
    dispatch(addEntry());
  }


  return (
    <Table className="spacing" captionSide="bottom">
      <thead>
        <tr>
          <th>Attribute</th>
          <th>Value</th>
          <th></th>
        </tr>
      </thead>

      <tbody>
        {initialInputValues.map((v, i) => (
          <tr>
            <th>
              <TextInput
                value={v.attribute}
                onChange={(event: React.ChangeEvent<HTMLInputElement>) =>
                  onAttributeChange(i, event.currentTarget.value)
                }
              />
            </th>

            <th>
              <TextInput
                value={v.content}
                onChange={(event: React.ChangeEvent<HTMLInputElement>) =>
                  onContentChange(i, event.currentTarget.value)
                }
              />
            </th>

            <th>
              <ActionIcon variant="filled" color="red">
                <IconTrash onClick={() => onRemoveClick(i)} />
              </ActionIcon>
            </th>
          </tr>
        ))}
      </tbody>

      <caption>
        <Group position="right" mr={15}>
          <Button
            color="green.7"
            leftIcon={<IconNewSection />}
            onClick={onAddAttributeClick}
          >
            Add Attribute
          </Button>
        </Group>
      </caption>
    </Table>
  );
}

export default AttributeTable;
