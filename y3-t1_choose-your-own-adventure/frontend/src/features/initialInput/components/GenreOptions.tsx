import { ReactElement } from "react";
import { IconAlertOctagon, IconAlien, IconFlare, IconSearch, IconWand, IconWriting } from "@tabler/icons-react";


export enum GenreOption {
  None = "",
  Fantasy = "Fantasy",
  Mystery = "Mystery",
  ScienceFiction = "Science Fiction",
  Dystopian = "Dystopian",
  Custom = "Custom Paragraph",
  Advanced = "Advanced Specification",
}

export interface GenreOptionMeta {
  value: string;
  label: string;
  icon: ReactElement;
  description?: string;
}

export const genreOptionsMeta: GenreOptionMeta[] = [
  { value: GenreOption.Fantasy, label: GenreOption.Fantasy, icon: <IconWand color="black" /> },
  { value: GenreOption.Mystery, label: GenreOption.Mystery, icon: <IconSearch color="black" /> },
  { value: GenreOption.ScienceFiction, label: GenreOption.ScienceFiction, icon: <IconAlien color="black" /> },
  { value: GenreOption.Dystopian, label: GenreOption.Dystopian, icon: <IconFlare color="black" /> },
  { value: GenreOption.Custom, label: GenreOption.Custom, icon: <IconWriting color="red" />, description: "Start with your own custom paragraph." },
  { value: GenreOption.Advanced, label: GenreOption.Advanced, icon: <IconAlertOctagon color="red" />, description: "Provide a theme, characters, story items, etc." },
];

// Mantine v7 grouped Select data format
export const genreOptionsData = [
  {
    group: "Pre-set genre options",
    items: [
      { value: GenreOption.Fantasy, label: GenreOption.Fantasy },
      { value: GenreOption.Mystery, label: GenreOption.Mystery },
      { value: GenreOption.ScienceFiction, label: GenreOption.ScienceFiction },
      { value: GenreOption.Dystopian, label: GenreOption.Dystopian },
    ],
  },
  {
    group: "User customization options",
    items: [
      { value: GenreOption.Custom, label: GenreOption.Custom },
      { value: GenreOption.Advanced, label: GenreOption.Advanced },
    ],
  },
];
