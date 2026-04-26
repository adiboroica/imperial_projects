/**
 * Save button — dispatches `saveGraph` and shows a spinner while the request is in flight.
 */

import { Button } from "@mantine/core";
import { useState } from "react";

import { useAppDispatch } from "../../../store/hooks";
import { saveGraph } from "../slices/graph";

const SaveButton = () => {
  const dispatch = useAppDispatch();
  const [saving, setSaving] = useState(false);

  const onClick = async () => {
    setSaving(true);
    await dispatch(saveGraph());
    setSaving(false);
  };

  return (
    <Button onClick={onClick} loading={saving} variant="filled">
      Save story
    </Button>
  );
};

export default SaveButton;
