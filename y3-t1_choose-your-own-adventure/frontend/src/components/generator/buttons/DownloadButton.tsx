import {
  Button, createStyles, Divider, Popover,
  Stack
} from "@mantine/core";
import { IconDownload } from "@tabler/icons";
import { selectStoryTitle } from "../../../store/features/storySlice";
import { useAppSelector } from "../../../store/hooks";
import { generateDocxFile, generateTxtFile } from "../../../utils/downloader/generationOfFiles";
import { StoryNode } from "../../../utils/graph/types";

const useStyles = createStyles((theme) => ({

  popover: {
    background: theme.white
  },
}));


interface DownloadButton {
  story: StoryNode[];
}

function DownloadButton(props: DownloadButton) {
  const { classes } = useStyles();

  const storyTitle = useAppSelector(selectStoryTitle);


  return (
    <Popover trapFocus position="bottom" withArrow shadow="md">
      <Popover.Target>
        <Button style={{ width: "40%" }}>
          <IconDownload />
        </Button>
      </Popover.Target>
      <Popover.Dropdown className={classes.popover}>
        <Stack spacing="xs">
          <Button
            compact
            variant="subtle"
            color="dark"
            onClick={() => generateDocxFile(props.story, storyTitle, true)}
          >
            as .docx
          </Button>

          <Divider />

          <Button
            compact
            variant="subtle"
            color="dark"
            onClick={() => generateTxtFile(props.story, storyTitle, true)}
          >
            as .txt
          </Button>
        </Stack>
      </Popover.Dropdown>
    </Popover>
  );
}

export default DownloadButton;
