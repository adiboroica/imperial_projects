import { ActionIcon, Group, Select, Text } from '@mantine/core';
import { forwardRef, ReactElement } from 'react';
import { genreOptionsData } from './GenreOptions';


interface GenreDropdownProps {
  genre: string;
  setGenre: React.Dispatch<React.SetStateAction<string>>;
}

function GenreDropdown(props: GenreDropdownProps) {
  
  return (
    <Select
      placeholder="Select a genre"
      clearable
      size="md"
      shadow='xl'
      maxDropdownHeight={400}
      onSearchChange={props.setGenre}
      searchValue={props.genre}
      nothingFound="No options"
      data={genreOptionsData}
      itemComponent={SelectItem}
    />
  )
};

export default GenreDropdown;


interface ItemProps extends React.ComponentPropsWithoutRef<'div'> {
  value: string;
  icon?: ReactElement;
  description?: string;
}

const SelectItem = forwardRef<HTMLDivElement, ItemProps>(
  ({ value, icon, description, ...others }: ItemProps, ref) => (
    <div ref={ref} {...others}>
      <Group noWrap>
        <ActionIcon size="md">
          {icon}
        </ActionIcon>
        <div>
          <Text size="sm">{value}</Text>
          <Text size="xs" opacity={0.65}>
            {description}
          </Text>
        </div>
      </Group>
    </div>
  )
);
