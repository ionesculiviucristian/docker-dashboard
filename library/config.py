import os
from dataclasses import dataclass
from typing import TypedDict

import yaml

from .env import envs
from .logger import logger

CONFIG_FILES = ["./config.yml", "./config.custom.yml"]

DEFAULT_PRIORITY = 999


class Config(TypedDict, total=False):
    profiles: dict[str, dict[str, int | None]]


@dataclass(frozen=True)
class DashboardConfig:
    services: list[str]


def load_config() -> DashboardConfig:
    logger.debug("Loading configuration files...")

    profile = envs.get("PROFILE")
    if not profile:
        profile = "default"
    logger.debug(f"Using {profile!r} profile")

    priorities: dict[str, int | None] = {}

    for file in CONFIG_FILES:
        if not os.path.isfile(file):
            continue

        with open(file, encoding="utf8") as stream:
            config: Config = yaml.safe_load(stream) or {}

        profiles = config.get("profiles", {})
        if profile in profiles:
            priorities = profiles[profile]
        logger.debug(f"Loaded {file!r} configuration file")

    if not priorities:
        raise Exception(f"Profile {profile!r} not found")

    def priority(service: str) -> int:
        value = priorities[service]
        return value if value is not None else DEFAULT_PRIORITY

    services = sorted(priorities, key=lambda service: (priority(service), service))

    return DashboardConfig(services=services)


config = load_config()
