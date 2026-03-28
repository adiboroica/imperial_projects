import {
  Button, Divider, Popover,
  Stack
} from "@mantine/core";
import { IconDownload } from "@tabler/icons-react";
import { selectStoryTitle } from "../../../store/features/storySlice";
import { useAppSelector } from "../../../store/hooks";
import { generateDocxFile, generateTxtFile } from "../../../utils/downloader/generationOfFiles";
import { StoryNode } from "../../../utils/graph/types";

import classes from './DownloadButton.module.css';


interface DownloadButton {
  story: StoryNode[];
}

function DownloadButton(props: DownloadButton) {

  const storyTitle = useAppSelector(selectStoryTitle);


  return (
    <Popover trapFocus position="bottom" withArrow shadow="md">
      <Popover.Target>
        <Button style={{ width: "40%" }}>
          <IconDownload />
        </Button>
      </Popover.Target>
      <Popover.Dropdown className={classes.popover}>
        <Stack gap="xs">
          <Button
            size="compact-sm"
            variant="subtle"
            color="dark"
            onClick={() => generateDocxFile(props.story, storyTitle, true)}
          >
            as .docx
          </Button>

          <Divider />

          <Button
            size="compact-sm"
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
