/**
 * Signup page — email + password form. Dispatches the `signup` thunk from the
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
  selectAuthError,
  signup,
} from "../../features/auth/slices/auth";
import { useAppDispatch, useAppSelector } from "../../store/hooks";
import { DASHBOARD_PAGE, LOGIN_PAGE } from "../../utils/routes";

const SignupPage = () => {
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const error = useAppSelector(selectAuthError);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    const result = await dispatch(signup({ email, password }));
    setSubmitting(false);
    if (signup.fulfilled.match(result)) {
      navigate(DASHBOARD_PAGE);
    }
  };

  return (
    <Container size="xs" py="xl">
      <Paper withBorder shadow="sm" p="xl" radius="md">
        <Title order={2} mb="md" ta="center">
          Sign up
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
              minLength={8}
              description="Minimum 8 characters"
              value={password}
              onChange={(e) => setPassword(e.currentTarget.value)}
            />
            {error && <div style={{ color: "red" }}>{error}</div>}
            <Button type="submit" loading={submitting} fullWidth>
              Sign up
            </Button>
            <Anchor component={Link} to={LOGIN_PAGE} ta="center" size="sm">
              Already have an account? Log in
            </Anchor>
          </Stack>
        </form>
      </Paper>
    </Container>
  );
};

export default SignupPage;
