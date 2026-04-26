/**
 * Download button — primary `.docx` action with a `.txt` fallback in the
 * dropdown. Wraps the page-local `SplitButton` widget.
 *
 * Export runs server-side (`GET /stories/{id}/export?format=...`); the browser
 * handles the actual download via `Content-Disposition: attachment`. No
 * client-side blob construction here.
 */

import { Button } from "@mantine/core";

import { stories } from "../../../api";
import SplitButton from "./SplitButton";

type Props = {
  storyId: string;
};

const DownloadButton = ({ storyId }: Props) => {
  if (!storyId) return null;
  const docxUrl = stories.exportUrl(storyId, "docx");
  const txtUrl = stories.exportUrl(storyId, "txt");
  return (
    <SplitButton
      text="Download .docx"
      disabled={false}
      confirmation={false}
      onClick={() => {
        window.location.assign(docxUrl);
      }}
    >
      <Button component="a" href={txtUrl} download variant="subtle" fullWidth>
        Download .txt
      </Button>
    </SplitButton>
  );
};

export default DownloadButton;
