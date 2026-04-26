# Setup Tests

Test contract for the new-story setup form.

## 📋 Overview

Five units: the page, the slice, the two form components with non-trivial logic (`AttributeTable`, `GenreHandler`), and the remaining presentational form components (treated as a group). Test files co-located alongside source.

## ▶️ Running

    npm test -- src/pages/setup

See [`../../../tests/README.md`](../../../tests/README.md) for the full test runner commands.

## 🧪 SetupPage

Form layout. Reads form state from the slice, dispatches changes on input, dispatches `startStory` on submit.

### Core Functionality

| Area              | Description                                                                |
| ----------------- | -------------------------------------------------------------------------- |
| Render form       | Renders genre dropdown, attribute table, free-text inputs, submit button.  |
| Field updates     | Editing any field dispatches the matching slice action.                    |
| Submit dispatches | Submit dispatches `startStory()` with the gathered theme + attributes.     |
| Success navigate  | On `startStory.fulfilled`, navigates to `/generator/:id`.                  |

### Edge Cases

| Case                  | Expected Behaviour                                              |
| --------------------- | --------------------------------------------------------------- |
| Empty genre on submit | Submit is blocked; inline error highlights the dropdown.        |
| `startStory.rejected` | Toast surfaces error; form stays editable; navigation cancels.  |

## 🧪 setup slice

Holds form state (selected genre, attribute rows) and the `startStory` thunk.

### Core Functionality

| Area                        | Description                                                              |
| --------------------------- | ------------------------------------------------------------------------ |
| Field reducers              | `setGenre`, `addAttribute`, `removeAttribute`, `updateAttribute` mutate state immutably. |
| `startStory.pending`        | Sets `submitting: true`.                                                  |
| `startStory.fulfilled`      | Returns the new story id; resets the form.                                |
| `startStory.rejected`       | Sets `submitting: false`; populates `error`; form stays.                  |

### Edge Cases

| Case                        | Expected Behaviour                                                |
| --------------------------- | ----------------------------------------------------------------- |
| Reset between sessions      | The form is restored to defaults when the page is re-entered after a successful submit. |

## 🧪 AttributeTable

List of `InputTextForm` rows plus an "Add attribute" button. Presentational — rows come from props, mutations are delegated to the parent's callbacks.

### Core Functionality

| Area                  | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| Render rows           | Renders one `InputTextForm` per `rows` entry, plus the static "Attributes" title. |
| Add dispatches        | The "Add attribute" button fires `onAdd`.                    |
| Disabled prop         | When `disabled` is true, the Add button is non-interactive.  |

### Edge Cases

| Case                  | Expected Behaviour                                              |
| --------------------- | --------------------------------------------------------------- |
| Empty `rows` list     | Renders the title and the Add button only; no input rows.       |

## 🧪 GenreHandler

Switches between dropdown (preset genre) and free-text (custom genre) modes via a Mantine `Switch`. Internal `customMode` state initialises from whether the supplied value is a known preset.

### Core Functionality

| Area                       | Description                                                            |
| -------------------------- | ---------------------------------------------------------------------- |
| Preset mode default        | When `value` is empty or matches a preset, renders the dropdown.       |
| Custom-mode entry on mount | When `value` does not match a preset, starts in custom mode with the value pre-filled. |
| Toggle on                  | Flicking the `Custom` switch swaps to a free-text input.               |
| Custom edits propagate     | Editing the free-text input fires `onChange` with the typed value.     |

### Edge Cases

| Case                       | Expected Behaviour                                                |
| -------------------------- | ----------------------------------------------------------------- |
| Toggle off clears value    | Flicking `Custom` off fires `onChange("")` so the parent resets.  |

## 🧪 Other form components

`GenreDropdown`, `GenreOptions`, `InputTextForm`, `GenerateButton` — all thin Mantine wrappers exercised through the `SetupPage` integration test rather than directly. See [`../../../tests/README.md#-what-we-test-and-what-we-dont`](../../../tests/README.md) for the rule.

### Core Functionality

| Area                       | Description                                                  |
| -------------------------- | ------------------------------------------------------------ |
| Controlled inputs          | Each component renders the value from props and fires `onChange` on edit. |
| `GenreDropdown` open       | Clicking opens a Mantine select; selecting fires `onChange`. |
| `GenerateButton` submit    | Click fires the `onSubmit` callback.                         |

### Edge Cases

| Case                       | Expected Behaviour                                              |
| -------------------------- | --------------------------------------------------------------- |
| Empty value                | Renders the placeholder; `onChange` not fired until edit.       |
| `GenerateButton` disabled  | Click is a no-op when `disabled` is true.                       |
