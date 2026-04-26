/**
 * ApiKeyForm — input + save button for the user's OpenAI API key.
 *
 * Reads the current key from `state.auth.apiKey`; dispatches `updateApiKey`
 * on save. Page-local: only `AccountPage` mounts it.
 */

import { Button, Group, PasswordInput } from "@mantine/core";
import { useEffect, useState } from "react";

import {
  selectAuthApiKey,
  updateApiKey,
} from "../../../features/auth/slices/auth";
import { useAppDispatch, useAppSelector } from "../../../store/hooks";

const ApiKeyForm = () => {
  const dispatch = useAppDispatch();
  const storedKey = useAppSelector(selectAuthApiKey);
  const [value, setValue] = useState("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    setValue(storedKey ?? "");
  }, [storedKey]);

  const onSave = async () => {
    if (!value.trim()) return;
    setSaving(true);
    await dispatch(updateApiKey(value));
    setSaving(false);
  };

  return (
    <Group align="end">
      <PasswordInput
        label="API Key"
        placeholder="sk-…"
        value={value}
        onChange={(e) => setValue(e.currentTarget.value)}
        style={{ flex: 1 }}
      />
      <Button onClick={onSave} loading={saving} disabled={!value.trim()}>
        Save
      </Button>
    </Group>
  );
};

export default ApiKeyForm;
