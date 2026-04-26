/**
 * Account page — logged-in user info, API-key management, logout.
 */

import { Button, Container, Paper, Stack, Text, Title } from "@mantine/core";
import { useEffect } from "react";
import { useNavigate } from "react-router-dom";

import {
  getApiKey,
  logout,
  selectAuthUser,
} from "../../features/auth/slices/auth";
import { useAppDispatch, useAppSelector } from "../../store/hooks";
import { HOME_PAGE } from "../../utils/routes";
import ApiKeyForm from "./components/ApiKeyForm";

const AccountPage = () => {
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const user = useAppSelector(selectAuthUser);

  useEffect(() => {
    dispatch(getApiKey());
  }, [dispatch]);

  const onLogout = async () => {
    await dispatch(logout());
    navigate(HOME_PAGE);
  };

  return (
    <Container size="md" py="xl">
      <Stack gap="lg">
        <Title order={2}>Your account</Title>
        <Paper withBorder shadow="sm" p="lg" radius="md">
          <Stack gap="sm">
            <Text>
              Signed in as <strong>{user?.email}</strong>
            </Text>
            <Button color="red" variant="light" onClick={onLogout}>
              Log out
            </Button>
          </Stack>
        </Paper>
        <Paper withBorder shadow="sm" p="lg" radius="md">
          <Title order={4} mb="sm">
            OpenAI API Key
          </Title>
          <ApiKeyForm />
        </Paper>
      </Stack>
    </Container>
  );
};

export default AccountPage;
