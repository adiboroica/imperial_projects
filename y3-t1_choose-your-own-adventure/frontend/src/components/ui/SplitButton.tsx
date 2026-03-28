import { Group, Button, Popover, ActionIcon } from "@mantine/core"
import { IconChevronDown } from "@tabler/icons-react"
import classes from './SplitButton.module.css';

export type SplitButtonProps = {
  text: string,
  disabled: boolean,
  confirmation: boolean,
  onClick: () => void,
}

const SplitButton = (props: React.PropsWithChildren<SplitButtonProps>) => {

  const MainButton = (
    <Button
      disabled={props.disabled}
      variant="outline"
      className={classes.splitButton}
      onClick={props.confirmation ? undefined : props.onClick}
    >
      {props.text}
    </Button>
  );



  return (
    <Group wrap="nowrap" gap={0} justify="center">
      {props.confirmation
        ?
        <Popover position="bottom" withArrow shadow="md">
          <Popover.Target>
            {MainButton}
          </Popover.Target>

          <Popover.Dropdown>
            <Button variant="subtle" className={classes.buttonStack} onClick={props.onClick}>
              Confirm:<br />{props.text}
            </Button>
          </Popover.Dropdown>
        </Popover>
        :
        MainButton
      }

      <Popover position="bottom" withArrow shadow="md">
        <Popover.Target>
          <ActionIcon
            disabled={props.disabled}
            variant="outline"
            size={36}
            className={classes.splitMenu}
          >
            <IconChevronDown size={16} stroke={1.5} />
          </ActionIcon>
        </Popover.Target>

        <Popover.Dropdown >
          {props.children}
        </Popover.Dropdown>
      </Popover>
    </Group>
  );
}

export default SplitButton;
