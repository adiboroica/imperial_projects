/**
 * GenreDropdown — Mantine `Select` over a fixed list of genres.
 *
 * Presentational: `value` and `onChange` come from `GenreHandler`, which
 * decides whether to show this dropdown or the free-text fallback.
 */

import { Select } from "@mantine/core";

import { GENRE_OPTIONS } from "./GenreOptions";

type Props = {
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
};

const GenreDropdown = ({ value, onChange, disabled }: Props) => {
  // Mantine `Select` returns `null` when cleared.
  return (
    <Select
      label="Genre"
      placeholder="Pick a genre"
      data={[...GENRE_OPTIONS]}
      value={value || null}
      onChange={(v) => onChange(v ?? "")}
      searchable
      clearable
      disabled={disabled}
    />
  );
};

export default GenreDropdown;
