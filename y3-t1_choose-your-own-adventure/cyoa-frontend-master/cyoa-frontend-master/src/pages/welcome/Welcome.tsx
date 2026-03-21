import { Button, Container, createStyles, Group, Image, Stack, Text, Title } from '@mantine/core';
import { IconCaretRight } from '@tabler/icons';
import { Link } from 'react-router-dom';
import '../../style/base.css';
import { DASHBOARD_PAGE } from '../../utils/pages';


const useStyles = createStyles((theme, _params) => ({

  titleStack: {
    justifyContent: "center",
    align: "center",
    spacing: "xl",
    width: "100",
    height: "92vh",
    alignItems: "center"
  },

  title: {
    textAlign: "center",
    fontSize: 55,
    fontWeight: 700,
    width: "80vw",
    tracking: "tight",
    letterSpacing: "-1px",
    fontFamily: 'Greycliff CF, sans-serif',
  },

  subtitle: {
    variant: "gradient",
    textAlign: "center",
    fontSize: 18,
    color: theme.colors.dark[4],
    fontWeight: 80,
    fontFamily: 'Greycliff CF, sans-serif'
  },

  startButton: {

  },

  stackContent: {
    alignItems: "center",
    justifyContent: "center",
    spacing: "xl",
    width: "100",
    background: theme.fn.gradient({ from: 'white', to: 'transparent', deg: 180 })
  },

  group: {
    width: "100",
    height: "60vh",
    alignItems: "center",
    background: "white",
    padding: "10px"
  },

  groupTall: {
    width: "100",
    height: "80vh",
    alignItems: "center",
    background: "white",
    padding: "10px"
  },

  groupShort: {
    width: "100",
    height: "40vh",
    alignItems: "center",
    padding: "10px"
  },

  textSubGroup: {
    width: "35vw"
  },

  endText: {
    fontSize: 40,
    fontWeight: 700,
    width: "80",
    tracking: "tight",
    letterSpacing: "-1px",
    fontFamily: 'Greycliff CF, sans-serif',
  }
}))

const WelcomeView = () => {
  const { classes } = useStyles();

  return (
    <>
      <Stack
        className={classes.titleStack}>
        <Text className={classes.title}>
          Choose Your Own Adventure Story Generator
        </Text>

        <Text className={classes.subtitle}>
          Quickly generate a complete, editable gamebook with a single prompt.
        </Text>

        <Link to={DASHBOARD_PAGE}>
          <Button
            variant="filled"
            color="indigo.8"
            size="md"
            radius="md"
            rightIcon={<IconCaretRight size={25} />}
          >
            Get Started
          </Button>
        </Link>
      </Stack >

      <Stack
        className={classes.stackContent}>
        <Group className={classes.group}>

          <Container className={classes.textSubGroup}>
            <Title>
              Create AI-generated stories with the click of a button
            </Title>
          </Container>

          <Image
            radius="md"
            src="img/first.gif"
            alt="Gif - generating story"
            width="35vw"
            fit="contain"
          />
        </Group>

        <Group className={classes.groupTall}>
          <Image
            radius="md"
            src="img/second.gif"
            alt="Gif - polishing story"
            width="35vw"
            fit="contain"
          />

          <Container className={classes.textSubGroup}>
            <Title>
              Easily polish and reorganize your story
            </Title>
          </Container>

        </Group>
        
        <Group className={classes.group}>

          <Container className={classes.textSubGroup}>
            <Title>
              Fine-tune the flow of your story
            </Title>
          </Container>

          <Image
            radius="md"
            src="img/third.gif"
            alt="Gif - showing settings"
            width="35vw"
            fit="contain"
          />
        </Group>

        <Group className={classes.group}>
          <Image
            radius="md"
            src="img/fourth.gif"
            alt="Gif - showing dashboard"
            width="35vw"
            fit="contain"
          />

          <Container className={classes.textSubGroup}>
            <Title>
              Keep your work on multiple stories
            </Title>
          </Container>

        </Group>

        <Group className={classes.groupShort}>
          <Link to={DASHBOARD_PAGE}>
            <Text
              variant="gradient"
              gradient={{ from: 'indigo.9', to: 'blue', deg: 45 }}
              className={classes.endText}
            >
              Start writing now.
            </Text>
          </Link>
        </Group>
      </Stack>

    </>
  );
};

export default WelcomeView;
