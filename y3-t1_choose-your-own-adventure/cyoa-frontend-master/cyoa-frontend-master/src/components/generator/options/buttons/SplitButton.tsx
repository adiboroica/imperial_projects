import { Group, Button, Popover, ActionIcon, createStyles } from "@mantine/core"
import { IconChevronDown } from "@tabler/icons"

const useStyles = createStyles((theme) => ({

  buttonStack: {
    textAlign: "center"
  },

  splitButton: {
    width: "100%",
    textAlign: "center",
    borderTopRightRadius: 0,
    borderBottomRightRadius: 0,
    borderRight: `0.5px solid`,
  },

  splitMenu: {
    borderTopLeftRadius: 0,
    borderBottomLeftRadius: 0,
    // border: 0,
    borderLeft: `0.5px solid`,
  },
}));


export type SplitButtonProps = {
  text: string,
  disabled: boolean,
  confirmation: boolean,
  onClick: () => void,
}

const SplitButton = (props: React.PropsWithChildren<SplitButtonProps>) => {
  const { classes } = useStyles();


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
    <Group noWrap spacing={0} position="center">
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