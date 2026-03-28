import { useCallback, useState } from 'react';
import {
  UnstyledButton,
  Menu,
  Group,
  Text,
} from '@mantine/core';
import {
  IconLogout,
  IconSettings,
  IconChevronDown,
  IconUserCircle,
  IconLogin,
} from '@tabler/icons-react';
import clsx from 'clsx';
import { useNavigate } from 'react-router-dom';
import { ACCOUNT_PAGE, LOGIN_PAGE } from '../../utils/routes';
import { useAppDispatch, useAppSelector } from '../../store/hooks';
import { logout, selectLoggedIn } from '../../store/features/accountSlice';
import classes from './AppMenu.module.css';


export default function AppMenu() {
  const navigate = useNavigate();
  const dispatch = useAppDispatch();

  const [userMenuOpened, setUserMenuOpened] = useState(false);

  const loggedIn = useAppSelector(selectLoggedIn);

  const onClickLogout = useCallback(() => {
    dispatch(logout());
  }, [dispatch]);


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
          className={clsx(classes.user, { [classes.userActive]: userMenuOpened })}
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
        {
          loggedIn ?
            <Menu.Item leftSection={<IconLogout size={14} stroke={1.5} />} onClick={onClickLogout}>
              Log Out
            </Menu.Item>
            :
            <Menu.Item leftSection={<IconLogin size={14} stroke={1.5} />} onClick={() => navigate(LOGIN_PAGE)}>
            Log In
            </Menu.Item>
        }
      </Menu.Dropdown>
    </Menu>
  );
}
