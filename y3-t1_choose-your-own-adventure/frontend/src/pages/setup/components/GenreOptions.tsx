/**
 * GenreOptions — the canonical list of genres exposed via the dropdown.
 *
 * The user can also type a free-form genre via `GenreHandler`'s "custom"
 * mode; this list is just the convenience preset.
 */

export const GENRE_OPTIONS: readonly string[] = [
  "fantasy",
  "sci-fi",
  "mystery",
  "horror",
  "adventure",
  "romance",
  "thriller",
  "historical",
] as const;

/**
 * Stub component so consumers can `import GenreOptions` if they want a
 * stand-alone listing. The list is exported as data above; this component
 * lets pages drop a quick reference UI in.
 */
import { List, Text } from "@mantine/core";

const GenreOptions = () => (
  <div>
    <Text size="sm" c="dimmed" mb="xs">
      Suggested genres
    </Text>
    <List size="sm">
      {GENRE_OPTIONS.map((g) => (
        <List.Item key={g}>{g}</List.Item>
      ))}
    </List>
  </div>
);

export default GenreOptions;
