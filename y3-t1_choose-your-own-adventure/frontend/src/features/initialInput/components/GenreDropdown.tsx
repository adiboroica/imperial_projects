import { ActionIcon, Group, Select, Text } from '@mantine/core';
import { genreOptionsData, genreOptionsMeta } from './GenreOptions';


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
      comboboxProps={{ shadow: 'xl' }}
      maxDropdownHeight={400}
      onSearchChange={props.setGenre}
      searchValue={props.genre}
      nothingFoundMessage="No options"
      data={genreOptionsData}
      renderOption={({ option }) => {
        const meta = genreOptionsMeta.find(d => d.value === option.value);
        return (
          <Group wrap="nowrap">
            <ActionIcon size="md" variant="transparent">
              {meta?.icon}
            </ActionIcon>
            <div>
              <Text size="sm">{option.label}</Text>
              {meta?.description && (
                <Text size="xs" opacity={0.65}>
                  {meta.description}
                </Text>
              )}
            </div>
          </Group>
        );
      }}
    />
  )
};

export default GenreDropdown;
