import os
import subprocess
import time

from .env import ENV_CUSTOM_FILE, ENV_FILE
from .logger import logger
from .setup import CmdException, run_cmd


class Docker:
    @staticmethod
    def start_containers(files: list[str], recreate: bool = False, remove_orphans: bool = False) -> None:
        if not files:
            raise ValueError("files is required")

        logger.info(
            "%s containers from %d compose files...", "Re-creating and starting" if recreate else "Starting", len(files)
        )

        file_flags = Docker._get_compose_file_flags(files)
        env_flags = Docker._get_compose_env_file_flags()
        up_flags = "-d"

        if recreate:
            up_flags += " --force-recreate"
        if remove_orphans:
            up_flags += " --remove-orphans"

        run_cmd(f"docker compose {file_flags} {env_flags} up {up_flags}")

    @staticmethod
    def stop_containers(files: list[str]) -> None:
        if not files:
            raise ValueError("files is required")

        logger.info(f"Stopping containers from {len(files)} compose files...")

        file_flags = Docker._get_compose_file_flags(files)
        env_flags = Docker._get_compose_env_file_flags()

        run_cmd(f"docker compose {file_flags} {env_flags} down --remove-orphans")

    @staticmethod
    def reset_containers() -> None:
        logger.info("Resetting containers...")

        env_file_flags = Docker._get_compose_env_file_flags()

        run_cmd(f"docker compose {env_file_flags} stop")
        run_cmd(f"docker compose {env_file_flags} rm --force")
        run_cmd(f"docker compose {env_file_flags} down --volumes --remove-orphans")

    @staticmethod
    def create_network(name: str) -> None:
        if not name:
            raise ValueError("name is required")

        logger.debug(f"Creating {name!r} docker network...")

        try:
            run_cmd(f"docker network inspect {name}")
            return
        except CmdException:
            pass

        run_cmd(f"docker network create {name}")

    @staticmethod
    def exec(container: str, cmd: str) -> subprocess.CompletedProcess[str]:
        if not container:
            raise ValueError("container is required")
        if not cmd:
            raise ValueError("cmd is required")

        return run_cmd(f"docker compose exec --no-tty {container} {cmd}")

    @staticmethod
    def wait_for_container(container: str, cmd: str, timeout: int = 60) -> None:
        if not container:
            raise ValueError("container is required")
        if not cmd:
            raise ValueError("cmd is required")

        logger.debug(f"Waiting {timeout}s for {container!r} container to be ready...")

        deadline = time.time() + timeout

        while time.time() < deadline:
            try:
                result = Docker.exec(container, cmd)
                if not result.returncode:
                    return
            except CmdException:
                time.sleep(1)

        raise Exception(f"Container {container!r} did not become ready within the specified time")

    @staticmethod
    def _get_compose_file_flags(files: list[str]) -> str:
        return " ".join(f"--file {f}" for f in files)

    @staticmethod
    def _get_compose_env_file_flags() -> str:
        return f"--env-file {ENV_FILE} --env-file {ENV_CUSTOM_FILE}" if os.path.isfile(ENV_CUSTOM_FILE) else ""
