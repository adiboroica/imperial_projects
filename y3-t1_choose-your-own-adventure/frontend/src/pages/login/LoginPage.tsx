/**
 * Login page — email + password form. Dispatches the `login` thunk from the
 * auth feature; navigates to `/dashboard` on success.
 */

import {
  Anchor,
  Button,
  Container,
  Paper,
  PasswordInput,
  Stack,
  TextInput,
  Title,
} from "@mantine/core";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";

import {
  login,
  selectAuthError,
} from "../../features/auth/slices/auth";
import { useAppDispatch, useAppSelector } from "../../store/hooks";
import { DASHBOARD_PAGE, SIGNUP_PAGE } from "../../utils/routes";

const LoginPage = () => {
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const error = useAppSelector(selectAuthError);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    const result = await dispatch(login({ email, password }));
    setSubmitting(false);
    if (login.fulfilled.match(result)) {
      navigate(DASHBOARD_PAGE);
    }
  };

  return (
    <Container size="xs" py="xl">
      <Paper withBorder shadow="sm" p="xl" radius="md">
        <Title order={2} mb="md" ta="center">
          Log in
        </Title>
        <form onSubmit={onSubmit}>
          <Stack gap="md">
            <TextInput
              label="Email"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.currentTarget.value)}
            />
            <PasswordInput
              label="Password"
              required
              value={password}
              onChange={(e) => setPassword(e.currentTarget.value)}
            />
            {error && <div style={{ color: "red" }}>{error}</div>}
            <Button type="submit" loading={submitting} fullWidth>
              Log in
            </Button>
            <Anchor component={Link} to={SIGNUP_PAGE} ta="center" size="sm">
              No account? Sign up
            </Anchor>
          </Stack>
        </form>
      </Paper>
    </Container>
  );
};

export default LoginPage;
