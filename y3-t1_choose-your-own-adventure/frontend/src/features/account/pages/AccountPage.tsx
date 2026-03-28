import { Container, Loader, TextInput, Divider, Text, Center } from "@mantine/core";
import { useEffect } from "react";
import ApiKeyForm from "../components/ApiKeyForm";
import { getApiKey, selectApiKey, selectEmail } from "../../../store/features/accountSlice";
import { useAppDispatch, useAppSelector } from "../../../store/hooks";

function AccountView() {

  const dispatch = useAppDispatch();

  const email = useAppSelector(selectEmail);
  const apiKey = useAppSelector(selectApiKey);

  const loaded = apiKey !== undefined;


  useEffect(() => {
    dispatch(getApiKey());
  }, [dispatch]);



  const ApiKeyInstructions = () => {
    return (
      <>
        <Divider mb={15} />
        <Text fz="sm" fw={400}>
          Our software uses OpenAI's language models to generate stories.
          Though we have set default API keys to access the model, you can supply your own to achieve faster and more consistent generation speeds.
          <Text td="underline" mt={8}>To get and use your own API key, you can:</Text>
          <Text ml={24} mt={3} mb={8}>
            <Text>1. Create a free account on <a target="_blank" href="https://platform.openai.com/signup">OpenAI</a>.</Text>
            <Text>2. Navigate to your OpenAI <a target="_blank" href="https://platform.openai.com/api-keys">API keys page</a> and generate a new key.</Text>
            <Text>3. Copy and paste your key into the form above.</Text>
          </Text>
          <Text fs="italic" >  ** Do note that OpenAI charges a fee based on your monthly usage beyond initially given free credits.</Text>
        </Text>
      </>
    );
  }

  const Content = () => {

    if (!loaded) {
      return (
        <Center style={{ height: 200 }}>
          <Loader />
        </Center>
      );
    }

    return (
      <>
        <TextInput label="Email" variant="filled" disabled={true} mb="lg"
          value={email}
        />
        <ApiKeyForm apiKey={apiKey === undefined ? "" : apiKey} />
        <ApiKeyInstructions />
      </>
    );
  }


  return (
    <Container className="wrapper">
      <Content />
    </Container>
  );
}

export default AccountView;
