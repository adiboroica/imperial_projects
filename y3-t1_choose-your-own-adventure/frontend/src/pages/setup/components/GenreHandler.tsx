/**
 * GenreHandler — chooses between dropdown and free-text genre entry.
 *
 * When the user picks "Other" or types a genre that isn't in `GENRE_OPTIONS`,
 * the handler swaps to a `TextInput` so they can write something custom.
 */

import { Group, Switch, TextInput } from "@mantine/core";
import { useState } from "react";

import GenreDropdown from "./GenreDropdown";
import { GENRE_OPTIONS } from "./GenreOptions";

type Props = {
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
};

const GenreHandler = ({ value, onChange, disabled }: Props) => {
  const isCustom =
    value !== "" && !(GENRE_OPTIONS as readonly string[]).includes(value);
  const [customMode, setCustomMode] = useState<boolean>(isCustom);

  return (
    <Group align="end" wrap="nowrap">
      {customMode ? (
        <TextInput
          label="Genre"
          placeholder="custom genre"
          value={value}
          onChange={(e) => onChange(e.currentTarget.value)}
          style={{ flex: 1 }}
          disabled={disabled}
        />
      ) : (
        <div style={{ flex: 1 }}>
          <GenreDropdown value={value} onChange={onChange} disabled={disabled} />
        </div>
      )}
      <Switch
        label="Custom"
        checked={customMode}
        onChange={(e) => {
          setCustomMode(e.currentTarget.checked);
          if (!e.currentTarget.checked) onChange("");
        }}
        disabled={disabled}
      />
    </Group>
  );
};

export default GenreHandler;
