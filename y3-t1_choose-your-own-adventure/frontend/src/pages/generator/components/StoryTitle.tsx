/**
 * Inline-editable story title. Commits via the `updateStoryName` thunk.
 *
 * Wraps the page-local `EditableField` widget — the click-to-edit affordance,
 * Textarea expansion, and commit icon all live there.
 */

import { useAppDispatch, useAppSelector } from "../../../store/hooks";
import {
  selectStoryName,
  updateStoryName,
} from "../slices/graph";
import EditableField from "./EditableField";

const StoryTitle = () => {
  const dispatch = useAppDispatch();
  const name = useAppSelector(selectStoryName);

  const handleCommit = (next: string) => {
    const trimmed = next.trim();
    if (!trimmed || trimmed === name) return;
    void dispatch(updateStoryName(trimmed));
  };

  return <EditableField value={name} onCommit={handleCommit} />;
};

export default StoryTitle;
