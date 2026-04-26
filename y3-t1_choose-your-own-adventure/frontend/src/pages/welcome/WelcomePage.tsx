/**
 * Welcome — landing page at `/` for unauthenticated visitors. Logged-in
 * users are redirected to `/dashboard` by `App.tsx` and never see this.
 */

import { Button, Container, Group, Stack, Text, Title } from "@mantine/core";
import { Link } from "react-router-dom";

import { LOGIN_PAGE, SIGNUP_PAGE } from "../../utils/routes";

const WelcomePage = () => {
  return (
    <Container size="md" py="xl">
      <Stack align="center" gap="xl" mt="xl">
        <Title order={1} size="3.5rem" ta="center">
          Choose Your Own Adventure
        </Title>
        <Text size="lg" c="dimmed" ta="center" maw={600}>
          An AI-powered gamebook generator that turns a theme and a handful of
          attributes into a branching, explorable story graph.
        </Text>
        <Group>
          <Button component={Link} to={LOGIN_PAGE} size="lg">
            Log in
          </Button>
          <Button
            component={Link}
            to={SIGNUP_PAGE}
            size="lg"
            variant="default"
          >
            Sign up
          </Button>
        </Group>
      </Stack>
    </Container>
  );
};

export default WelcomePage;
