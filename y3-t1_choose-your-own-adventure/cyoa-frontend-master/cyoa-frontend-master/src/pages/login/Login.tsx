import { Button, createStyles, Group, PasswordInput, Stack, Text, TextInput, Title } from "@mantine/core";
import { FormEvent, useState } from "react";
import { Link } from "react-router-dom";
import {
  login, selectCredentialLoginFail
} from "../../store/features/accountSlice";
import { useAppDispatch, useAppSelector } from "../../store/hooks";
import { SIGNUP_PAGE } from "../../utils/pages";

const useStyles = createStyles((theme, _params) => ({

  box: {
    width: "100vw",
    height: "92vh",
    alignItems: "center",
  },

  stack: {
    backgroundColor: theme.white,
    height: 380,
    width: 320,
    borderRadius: 6,
    boxShadow: theme.shadows.md,
    padding: 20,
    margin: "auto",
    alignItems: "center"
  }
}))

const LoginView = () => {
  const { classes } = useStyles();

  const dispatch = useAppDispatch();
  const credentialsLoginFail = useAppSelector(selectCredentialLoginFail);

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");


  const onLoginSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    dispatch(login({ email, password }));
  }


  return (
    <Group
      className={classes.box}>
      <Stack className={classes.stack} >
        <Title order={2}>Log In</Title>

        <form onSubmit={onLoginSubmit}>
          <TextInput
            label="Email"
            variant="filled"
            placeholder="your@email.com"
            value={email}
            onChange={(event: any) => setEmail(event.target.value)}
            mb="lg"
          />

          <PasswordInput
            placeholder="Password"
            label="Password"
            variant="filled"
            value={password}
            onChange={(event: any) => setPassword(event.target.value)}
          />
          {credentialsLoginFail &&
            <Text fz="xs" c="red">Invalid credentials.</Text>
          }

          <Stack mt="md">
            <Button
              type="submit"
              variant="gradient"
              gradient={{ from: 'violet', to: 'blue' }}>
              Login
            </Button>
            <Group position="center">
              <Link to={SIGNUP_PAGE}>
                <Text fz="sm" c="blue" td="underline">
                  Create an Account
                </Text>
              </Link>
            </Group>
          </Stack>
        </form>
      </Stack>
    </Group>
  )

}

export default LoginView;
