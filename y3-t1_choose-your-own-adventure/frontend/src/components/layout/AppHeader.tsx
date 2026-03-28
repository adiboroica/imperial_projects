import {
	Container, Flex, Group, Tabs
} from '@mantine/core';
import clsx from 'clsx';
import { useLocation, useNavigate } from 'react-router-dom';
import AppMenu from './AppMenu';
import classes from './AppHeader.module.css';


interface AppHeaderProps {
	links: { label: string, link: string; }[];
}

function AppHeader({ links }: AppHeaderProps) {
	const navigate = useNavigate();

	const location = useLocation();
	const activeLink = links.find((link) => link.link == location.pathname)?.link


	const linkTabs = links.map((link) => (
		<Tabs.Tab value={link.link} key={link.label}
			className={clsx(classes.tab, { [classes.tabActive]: activeLink === link.link })}
		>
			{link.label}
		</Tabs.Tab>
	));


	return (
		<div className={classes.header}>
			<Container>
				<Group
					justify="space-between"
					align="flex-end"
				>
					<Tabs
						variant="outline"
						classNames={{
							list: classes.tabsList,
						}}
						onChange={(value) => navigate(`${value}`)}
					>
						<Tabs.List>{linkTabs}</Tabs.List>
					</Tabs>

					<div className={classes.appMenu}>
						<AppMenu />
					</div>

				</Group>
			</Container>
		</div>
	);
}

export default AppHeader;
