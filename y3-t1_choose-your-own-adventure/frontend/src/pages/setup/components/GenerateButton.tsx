/**
 * GenerateButton — submit button for the setup form.
 *
 * Presentational: takes loading + disabled flags plus a click handler.
 */

import { Button } from "@mantine/core";

type Props = {
  loading?: boolean;
  disabled?: boolean;
  onClick?: () => void;
};

const GenerateButton = ({ loading, disabled, onClick }: Props) => (
  <Button
    type={onClick ? "button" : "submit"}
    loading={loading}
    disabled={disabled}
    onClick={onClick}
    size="md"
    mt="md"
  >
    Generate story
  </Button>
);

export default GenerateButton;
