import {
	Container, createStyles, Flex, Group, Tabs
} from '@mantine/core';
import { useLocation, useNavigate } from 'react-router-dom';
import AppMenu from './header/AppMenu';


const useStyles = createStyles((theme) => ({

	header: {
		backgroundColor: theme.fn.rgba(theme.black, 0.08),
		paddingTop: theme.spacing.sm,
		borderBottom: `1px solid ${theme.colors.gray[2]}`,
	},


	appMenu: {
		paddingBottom: theme.spacing.sm,
	},


	tabsList: {
		borderBottom: '0 !important',
	},
	tab: {
		backgroundColor: 'transparent',
		fontWeight: 500,

		'&:hover': {
			backgroundColor: theme.colors.gray[0],
		},
	},
	tabActive: {
		backgroundColor: theme.white,
		borderColor: theme.colors.gray[2],
	}
}));


interface AppHeaderProps {
	links: { label: string, link: string; }[];
}

function AppHeader({ links }: AppHeaderProps) {
	const { classes, cx } = useStyles();

	const navigate = useNavigate();

	const location = useLocation();
	const activeLink = links.find((link) => link.link == location.pathname)?.link


	const linkTabs = links.map((link) => (
		<Tabs.Tab value={link.link} key={link.label}
			className={cx(classes.tab, { [classes.tabActive]: activeLink === link.link })}
		>
			{link.label}
		</Tabs.Tab>
	));


	return (
		<div className={classes.header}>
			<Container>
				<Group
					position="apart"
					align="flex-end"
				>
					<Tabs
						variant="outline"
						classNames={{
							tabsList: classes.tabsList,
						}}
						onTabChange={(value) => navigate(`${value}`)}
					>
						<Tabs.List>{linkTabs}</Tabs.List>
					</Tabs>

					<div className={classes.appMenu}>
						<AppMenu />
					</div>

				</Group>
			</Container>
		</ div>
	);
}

export default AppHeader;
