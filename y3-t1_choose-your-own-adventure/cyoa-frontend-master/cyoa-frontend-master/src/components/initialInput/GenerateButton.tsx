import { IconCaretRight } from "@tabler/icons";
import { Button } from '@mantine/core';


interface GenerateButtonProps {
  className?: string;
  color?: string;
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
}

function GenerateButton(props: GenerateButtonProps) {

  return (
    <Button
      variant="filled"
      size="md"
      radius="md"
      rightIcon={<IconCaretRight size={25} />}
      {...props}
    >
      Generate
    </Button>
  );
};

export default GenerateButton;
