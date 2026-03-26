import { IconAlertOctagon, IconAlien, IconFlare, IconSearch, IconWand, IconWriting } from "@tabler/icons";


export enum GenreOption {
  None = "",
  Fantasy = "Fantasy",
  Mystery = "Mystery",
  ScienceFiction = "Science Fiction",
  Dystopian = "Dystopian",
  Custom = "Custom Paragraph",
  Advanced = "Advanced Specification",
}


export const genreOptionsData = [
  {
    value: GenreOption.Fantasy,
    label: GenreOption.Fantasy,
    icon: <IconWand color="black" />,
    group: "Pre-set genre options"
  },
  {
    value: GenreOption.Mystery,
    label: GenreOption.Mystery,
    icon: <IconSearch color="black" />,
    group: "Pre-set genre options"
  },
  {
    value: GenreOption.ScienceFiction,
    label: GenreOption.ScienceFiction,
    icon: <IconAlien color="black" />,
    group: "Pre-set genre options"
  },
  {
    value: GenreOption.Dystopian,
    label: GenreOption.Dystopian,
    icon: <IconFlare color="black" />,
    group: "Pre-set genre options"
  },
  {
    value: GenreOption.Custom,
    label: GenreOption.Custom,
    icon: <IconWriting color="red" />,
    description: "Start with your own custom paragraph.",
    group: "User customization options"
  },
  {
    value: GenreOption.Advanced,
    label: GenreOption.Advanced,
    icon: <IconAlertOctagon color="red" />,
    description: "Provide a theme, characters, story items, etc. ",
    group: "User customization options"
  }
]