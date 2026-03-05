import os
import shlex
import shutil
import tempfile
from typing import Literal

from dotenv import dotenv_values, load_dotenv, set_key

from .logger import logger
from .setup import run_cmd

ENV_FILE = "./.env"
ENV_CUSTOM_FILE = "./.env.custom"
ENV_EXAMPLE_FILE = "./.env.example"

type GenerateMethod = Literal["random", "hash"]


class Env:
    env_files: list[str] = []
    values: dict[str, dict[str, str | None]] = {}

    def __init__(self, *env_files: str):
        self.env_files = list(env_files)
        self.load()

    def load(self):
        logger.debug("Loading env files...")
        for env_file in self.env_files:
            if not os.path.isfile(env_file):
                continue
            self.values[env_file] = dotenv_values(env_file)
            load_dotenv(env_file, override=True)
            logger.debug(f"Loaded {env_file!r} env file...")

    def get(self, variable_name: str) -> str:
        if not variable_name:
            raise ValueError("variable_name is required")

        return os.environ.get(variable_name, "")

    def has(self, variable_name: str, custom: bool = False) -> bool:
        if not variable_name:
            raise ValueError("variable_name is required")

        values = self._get_values(custom)
        return variable_name in values

    def set(self, variable_name: str, value: str, custom: bool = False) -> None:
        if not variable_name:
            raise ValueError("variable_name is required")

        env_file = self._get_env_file(custom)
        set_key(env_file, variable_name, f'"{value}"', quote_mode="never")
        self.values[env_file][variable_name] = value
        self.load()

    def generate(
        self,
        *variable_names: str,
        method: GenerateMethod = "random",
        source: str | None = None,
        overwrite: bool = False,
        custom: bool = False,
    ) -> None:
        if not variable_names:
            raise ValueError("variable_names is required")

        for variable_name in variable_names:
            if not variable_name:
                raise ValueError("variable_name is required")

            if self._get_values(custom).get(variable_name) and not overwrite:
                continue

            self.set(variable_name, self._generate_value(method, source), custom)

    def _generate_value(self, method: GenerateMethod, source: str | None) -> str:
        match method:
            case "random":
                result = run_cmd("openssl rand -base64 64 | tr --delete '\\n'")
                return result.stdout
            case "hash":
                if source is None:
                    raise ValueError("source is required for the hash method")
                result = run_cmd(f"htpasswd -bnBC 10 '' {shlex.quote(source)} | tr --delete ':\\n'")
                return result.stdout.replace("$", "$$")
            case _:
                raise ValueError(f"Unknown generate method {method!r}")

    def _get_env_file(self, custom: bool = False):
        return ENV_CUSTOM_FILE if custom else ENV_FILE

    def _get_values(self, custom: bool = False):
        env_file = self._get_env_file(custom)
        if env_file not in self.values:
            raise Exception(f"{env_file} not loaded")
        return self.values[env_file]


def sync_env_file(envs: Env) -> None:
    with tempfile.NamedTemporaryFile(delete=False) as f:
        temp_file = f.name
    shutil.copy(ENV_EXAMPLE_FILE, temp_file)

    values = dotenv_values(ENV_FILE, interpolate=False)

    for key, value in values.items():
        if key.endswith("_VERSION"):
            continue
        set_key(temp_file, key, f'"{value}"', quote_mode="never")

    shutil.move(temp_file, ENV_FILE)
    envs.load()


envs = Env(ENV_FILE, ENV_CUSTOM_FILE)
