import { useCallback, useState } from 'react';
import {
  createStyles,
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
} from '@tabler/icons';
import { useNavigate } from 'react-router-dom';
import { ACCOUNT_PAGE, LOGIN_PAGE } from '../../utils/pages';
import { useAppDispatch, useAppSelector } from '../../store/hooks';
import { logout, selectLoggedIn } from '../../store/features/accountSlice';

const useStyles = createStyles((theme) => ({

  user: {
    color: theme.black,
    padding: '8px 12px',
    borderRadius: theme.radius.sm,
    transition: 'background-color 100ms ease',

    '&:hover': {
      backgroundColor: theme.white,
    },
  },
  userActive: {
    backgroundColor: theme.white,
  },
}));


export default function AppMenu() {
  const { classes, cx } = useStyles();

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
      transition="pop-top-right"
      onClose={() => setUserMenuOpened(false)}
      onOpen={() => setUserMenuOpened(true)}
    >
      <Menu.Target>
        <UnstyledButton
          className={cx(classes.user, { [classes.userActive]: userMenuOpened })}
        >
          <Group spacing={7}>
            <IconUserCircle size={12} />
            <Text weight={500} size="sm" sx={{ lineHeight: 1 }} mr={3} color="black">
              Account
            </Text>
            <IconChevronDown size={12} stroke={1.5} />
          </Group>
        </UnstyledButton>
      </Menu.Target>

      <Menu.Dropdown>
        <Menu.Label>Settings</Menu.Label>
        <Menu.Item
          icon={<IconSettings size={14} stroke={1.5} />}
          onClick={() => navigate(ACCOUNT_PAGE)}
        >
          Account settings
        </Menu.Item>
        {
          loggedIn ? 
            <Menu.Item icon={<IconLogout size={14} stroke={1.5} />} onClick={onClickLogout}>
              Log Out
            </Menu.Item>
            :
            <Menu.Item icon={<IconLogin size={14} stroke={1.5} />} onClick={() => navigate(LOGIN_PAGE)}>
            Log In
            </Menu.Item>
        }
      </Menu.Dropdown>
    </Menu>
  );
}