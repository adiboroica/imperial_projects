import os

import openai
from openai import OpenAI
from time import sleep

from src.constants import MAX_RATE_LIMIT_ERRORS, REQ_FAILURE_TIMEOUT_SECS

DEFAULT_MODEL = os.getenv("OPENAI_MODEL", "gpt-4.1")

SYSTEM_INSTRUCTIONS = (
    "You are a creative fiction writer specializing in adventure gamebook "
    "stories written in second person. Continue the story naturally. "
    "Output only the story text, no commentary or markdown formatting."
)


class OpenAIUnavailableError(Exception):

    pass

class OpenAIRateLimitError(Exception):

    pass

class APIKeyRoundRobinSelector:
    def __init__(self, user_api_key=None):
        self.curr_index: int = 0
        self.user_api_key = user_api_key
        self.keys: list[str] = [x.strip() for x in os.getenv("OPENAI_API_KEY").split(",")]

    def update_round_robin_index(self):
        if self.curr_index == len(self.keys) - 1:
            self.curr_index = 0
            return
        self.curr_index += 1

    def get_api_key(self) -> str:
        if self.user_api_key:
            return self.user_api_key
        next_key = self.keys[self.curr_index]
        self.update_round_robin_index()
        return next_key


def error_handling(func):
    def wrapper(self, *args, unavailable_count=0, rate_limit_count=0, **kwargs):
        self.rate_limited = False

        try:
            return func(self, *args, **kwargs)

        except openai.RateLimitError:
            print("rate limit error")

            if rate_limit_count >= MAX_RATE_LIMIT_ERRORS:
                raise OpenAIRateLimitError

            self.rate_limited = True
            sleep(REQ_FAILURE_TIMEOUT_SECS)

            return wrapper(self, *args, **kwargs,
                unavailable_count=unavailable_count, rate_limit_count=rate_limit_count+1)

        except openai.APIStatusError as e:
            if e.status_code == 503:
                raise OpenAIUnavailableError
            raise

        except openai.APIConnectionError:
            raise OpenAIUnavailableError

    return wrapper


class GPT3Model:

    def __init__(self, api_key=None, temperature=0.5, max_tokens=256) -> None:

        self.api_key = api_key
        self.rate_limited = False

        self.round_robin_scheduler = APIKeyRoundRobinSelector()

        self.temperature = temperature
        self.max_tokens = max_tokens

    def _create_client(self) -> OpenAI:
        return OpenAI(api_key=self.next_api_key)

    @error_handling
    def complete(self, prompt: str) -> str:
        client = self._create_client()
        response = client.responses.create(
            model=DEFAULT_MODEL,
            instructions=SYSTEM_INSTRUCTIONS,
            input=prompt,
            temperature=self.temperature,
            max_output_tokens=self.max_tokens,
        )
        return response.output_text

    @error_handling
    def insert(self, prompt: str, suffix: str) -> str:
        client = self._create_client()
        response = client.responses.create(
            model=DEFAULT_MODEL,
            instructions=(
                "You are a creative fiction writer. Write a passage that "
                "naturally connects the given prefix text to the suffix text. "
                "Output ONLY the connecting text, nothing else."
            ),
            input=f"Prefix:\n{prompt}\n\nSuffix:\n{suffix}\n\nWrite the connecting text:",
            temperature=self.temperature,
            max_output_tokens=self.max_tokens,
        )
        return response.output_text

    @error_handling
    def edit(self, text_to_edit: str, instruction: str) -> str:
        client = self._create_client()
        response = client.responses.create(
            model=DEFAULT_MODEL,
            instructions=(
                "You are a text editor. Apply the given instruction to modify "
                "the provided text. Output ONLY the modified text, nothing else."
            ),
            input=f"Text: {text_to_edit}\n\nInstruction: {instruction}",
            temperature=self.temperature,
        )
        return response.output_text

    @property
    def next_api_key(self):
        if self.api_key is None or self.rate_limited:
            return self.round_robin_scheduler.get_api_key()
        else:
            return self.api_key
