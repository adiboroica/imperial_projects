import { Button, Container, Group, Image, Stack, Text, Title } from '@mantine/core';
import { IconCaretRight } from '@tabler/icons-react';
import { Link } from 'react-router-dom';
import { DASHBOARD_PAGE } from '../../../utils/routes';
import classes from './WelcomePage.module.css';


const WelcomeView = () => {
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
            rightSection={<IconCaretRight size={25} />}
          >
            Get Started
          </Button>
        </Link>
      </Stack>

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
            w="35vw"
            fit="contain"
          />
        </Group>

        <Group className={classes.groupTall}>
          <Image
            radius="md"
            src="img/second.gif"
            alt="Gif - polishing story"
            w="35vw"
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
            w="35vw"
            fit="contain"
          />
        </Group>

        <Group className={classes.group}>
          <Image
            radius="md"
            src="img/fourth.gif"
            alt="Gif - showing dashboard"
            w="35vw"
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
