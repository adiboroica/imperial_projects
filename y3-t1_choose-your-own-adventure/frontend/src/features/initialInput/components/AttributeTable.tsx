import { Button, TextInput, Table, ActionIcon, Group, Container, Stack, Center } from '@mantine/core';
import './AttributeTable.css';
import { IconTrash, IconNewSection } from '@tabler/icons-react';
import { useAppDispatch, useAppSelector } from '../../../store/hooks';
import { addEntry, removeEntry, selectInitialInputValues, setAttribute, setContent } from '../../../store/features/initialInputSlice';


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
      <Table.Thead>
        <Table.Tr>
          <Table.Th>Attribute</Table.Th>
          <Table.Th>Value</Table.Th>
          <Table.Th></Table.Th>
        </Table.Tr>
      </Table.Thead>

      <Table.Tbody>
        {initialInputValues.map((v, i) => (
          <Table.Tr key={i}>
            <Table.Td>
              <TextInput
                value={v.attribute}
                onChange={(event: React.ChangeEvent<HTMLInputElement>) =>
                  onAttributeChange(i, event.currentTarget.value)
                }
              />
            </Table.Td>

            <Table.Td>
              <TextInput
                value={v.content}
                onChange={(event: React.ChangeEvent<HTMLInputElement>) =>
                  onContentChange(i, event.currentTarget.value)
                }
              />
            </Table.Td>

            <Table.Td>
              <ActionIcon variant="filled" color="red" onClick={() => onRemoveClick(i)}>
                <IconTrash />
              </ActionIcon>
            </Table.Td>
          </Table.Tr>
        ))}
      </Table.Tbody>

      <Table.Caption>
        <Group justify="flex-end" mr={15}>
          <Button
            color="green.7"
            leftSection={<IconNewSection />}
            onClick={onAddAttributeClick}
          >
            Add Attribute
          </Button>
        </Group>
      </Table.Caption>
    </Table>
  );
}

export default AttributeTable;
