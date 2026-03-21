import {
  Center, Container, createStyles, Text
} from '@mantine/core';


const useStyles = createStyles((theme) => ({

  footer: {
    backgroundColor: theme.fn.rgba(theme.black, 0.08),
    borderTop: `1px solid ${theme.colors.gray[2]}`,
  },
  footerInner: {
    padding: `${theme.spacing.md}px ${theme.spacing.md}px`,
  },


  text: {
    color: theme.black,
    fontWeight: 500,
  }
}));


function AppFooter() {
  const { classes } = useStyles();

  return (
    <div className={classes.footer}>
      <Container className={classes.footerInner}>
        <Center>
          <Text className={classes.text}>
            CYOA Story Generator
          </Text>
        </Center>
      </Container>
    </div >
  );
}

export default AppFooter;
