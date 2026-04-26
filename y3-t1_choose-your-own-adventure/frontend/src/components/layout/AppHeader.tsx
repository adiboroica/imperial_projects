/**
 * Top navigation bar — presentational. Takes `loggedIn`, `onLogout`, and the
 * tab links as props; `App.tsx` wires the store.
 */

import { Container, Group, Tabs } from "@mantine/core";
import clsx from "clsx";
import { useLocation, useNavigate } from "react-router-dom";

import AppMenu from "./AppMenu";
import classes from "./AppHeader.module.css";

type Link = { label: string; link: string };

type Props = {
  links: Link[];
  loggedIn: boolean;
  onLogout: () => void;
};

const AppHeader = ({ links, loggedIn, onLogout }: Props) => {
  const navigate = useNavigate();
  const location = useLocation();
  const activeLink = links.find((link) => link.link === location.pathname)?.link;

  const linkTabs = links.map((link) => (
    <Tabs.Tab
      value={link.link}
      key={link.label}
      className={clsx(classes.tab, {
        [classes.tabActive]: activeLink === link.link,
      })}
    >
      {link.label}
    </Tabs.Tab>
  ));

  return (
    <div className={classes.header}>
      <Container>
        <Group justify="space-between" align="flex-end">
          <Tabs
            variant="outline"
            classNames={{ list: classes.tabsList }}
            onChange={(value) => value && navigate(value)}
          >
            <Tabs.List>{linkTabs}</Tabs.List>
          </Tabs>
          <div className={classes.appMenu}>
            <AppMenu loggedIn={loggedIn} onLogout={onLogout} />
          </div>
        </Group>
      </Container>
    </div>
  );
};

export default AppHeader;
