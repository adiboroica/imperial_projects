/**
 * Account dropdown menu — presentational. `App.tsx` wires `loggedIn` and the
 * `onLogout` callback.
 */

import { Group, Menu, Text, UnstyledButton } from "@mantine/core";
import {
  IconChevronDown,
  IconLogin,
  IconLogout,
  IconSettings,
  IconUserCircle,
} from "@tabler/icons-react";
import clsx from "clsx";
import { useState } from "react";
import { useNavigate } from "react-router-dom";

import { ACCOUNT_PAGE, LOGIN_PAGE } from "../../utils/routes";
import classes from "./AppMenu.module.css";

type Props = {
  loggedIn: boolean;
  onLogout: () => void;
};

const AppMenu = ({ loggedIn, onLogout }: Props) => {
  const navigate = useNavigate();
  const [userMenuOpened, setUserMenuOpened] = useState(false);

  return (
    <Menu
      width={260}
      position="bottom-end"
      transitionProps={{ transition: "pop-top-right" }}
      onClose={() => setUserMenuOpened(false)}
      onOpen={() => setUserMenuOpened(true)}
    >
      <Menu.Target>
        <UnstyledButton
          className={clsx(classes.user, {
            [classes.userActive]: userMenuOpened,
          })}
        >
          <Group gap={7}>
            <IconUserCircle size={12} />
            <Text fw={500} size="sm" style={{ lineHeight: 1 }} mr={3} c="black">
              Account
            </Text>
            <IconChevronDown size={12} stroke={1.5} />
          </Group>
        </UnstyledButton>
      </Menu.Target>

      <Menu.Dropdown>
        <Menu.Label>Settings</Menu.Label>
        <Menu.Item
          leftSection={<IconSettings size={14} stroke={1.5} />}
          onClick={() => navigate(ACCOUNT_PAGE)}
        >
          Account settings
        </Menu.Item>
        {loggedIn ? (
          <Menu.Item
            leftSection={<IconLogout size={14} stroke={1.5} />}
            onClick={onLogout}
          >
            Log out
          </Menu.Item>
        ) : (
          <Menu.Item
            leftSection={<IconLogin size={14} stroke={1.5} />}
            onClick={() => navigate(LOGIN_PAGE)}
          >
            Log in
          </Menu.Item>
        )}
      </Menu.Dropdown>
    </Menu>
  );
};

export default AppMenu;
