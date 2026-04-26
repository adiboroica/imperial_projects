/**
 * Setup — new-story form. Pick a genre, fill in attributes, start generation.
 *
 * Page-local components live in `./components/`; this page wires the slice
 * state through to them.
 */

import { Container, Paper, Stack, Title } from "@mantine/core";
import { useNavigate } from "react-router-dom";

import { useAppDispatch, useAppSelector } from "../../store/hooks";
import { GENERATOR_PAGE } from "../../utils/routes";
import AttributeTable from "./components/AttributeTable";
import GenerateButton from "./components/GenerateButton";
import GenreHandler from "./components/GenreHandler";
import {
  addEntry,
  removeEntry,
  selectSetupGenre,
  selectSetupSubmitting,
  selectSetupValues,
  setAttribute,
  setContent,
  setGenre,
  startStory,
} from "./slices/setup";

const SetupPage = () => {
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const genre = useAppSelector(selectSetupGenre);
  const values = useAppSelector(selectSetupValues);
  const submitting = useAppSelector(selectSetupSubmitting);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const result = await dispatch(startStory());
    if (startStory.fulfilled.match(result)) {
      navigate(`${GENERATOR_PAGE}${result.payload.storyId}`);
    }
  };

  return (
    <Container size="md" py="xl">
      <Paper withBorder shadow="sm" p="xl" radius="md">
        <Title order={2} mb="lg">
          Start a new story
        </Title>
        <form onSubmit={onSubmit}>
          <Stack gap="md">
            <GenreHandler
              value={genre}
              onChange={(v) => dispatch(setGenre(v))}
              disabled={submitting}
            />

            <AttributeTable
              rows={values}
              onAttribute={(position, data) =>
                dispatch(setAttribute({ position, data }))
              }
              onContent={(position, data) =>
                dispatch(setContent({ position, data }))
              }
              onAdd={() => dispatch(addEntry())}
              onRemove={(position) => dispatch(removeEntry({ position }))}
              disabled={submitting}
            />

            <GenerateButton loading={submitting} disabled={!genre.trim()} />
          </Stack>
        </form>
      </Paper>
    </Container>
  );
};

export default SetupPage;
