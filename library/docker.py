import os
import subprocess
import time

from .env import ENV_CUSTOM_FILE, ENV_FILE
from .logger import logger
from .setup import CmdException, run_cmd


class DockerException(Exception):
    pass


class _Manager:
    def __init__(self, docker: Docker):
        self._docker = docker


class _ComposeManager(_Manager):
    def up(self, recreate: bool = False, remove_orphans: bool = False) -> None:
        files = self._docker.files
        if not files:
            raise ValueError("files is required")

        logger.info(
            "%s containers from %d compose files...", "Re-creating and starting" if recreate else "Starting", len(files)
        )

        flags = "-d"
        if recreate:
            flags += " --force-recreate"
        if remove_orphans:
            flags += " --remove-orphans"

        run_cmd(f"docker compose {self._docker.file_flags} {self._docker.env_file_flags} up {flags}")

    def down(self, remove_orphans: bool = True) -> None:
        files = self._docker.files
        if not files:
            raise ValueError("files is required")

        logger.info(f"Stopping containers from {len(files)} compose files...")

        flags = " --remove-orphans" if remove_orphans else ""

        run_cmd(f"docker compose {self._docker.file_flags} {self._docker.env_file_flags} down{flags}")

    def reset(self) -> None:
        logger.info("Resetting containers...")

        env_file_flags = self._docker.env_file_flags

        run_cmd(f"docker compose {env_file_flags} stop")
        run_cmd(f"docker compose {env_file_flags} rm --force")
        run_cmd(f"docker compose {env_file_flags} down --volumes --remove-orphans")


class _ContainerManager(_Manager):
    def exec(self, container: str, cmd: str) -> subprocess.CompletedProcess[str]:
        if not container:
            raise ValueError("container is required")
        if not cmd:
            raise ValueError("cmd is required")

        return run_cmd(f"docker compose exec --no-tty {container} {cmd}")

    def send_signal(self, container: str, signal: str) -> None:
        if not container:
            raise ValueError("container is required")
        if not signal:
            raise ValueError("signal is required")

        logger.debug(f"Sending {signal!r} to {container!r} container...")

        run_cmd(f"docker compose kill --signal {signal} {container}")

    def get_id(self, container: str) -> str | None:
        if not container:
            raise ValueError("container is required")

        try:
            result = run_cmd(f"docker compose ps --quiet {container}")
        except CmdException:
            return None

        return result.stdout.strip() or None

    def get_health_status(self, container: str) -> str | None:
        if not container:
            raise ValueError("container is required")

        container_id = self.get_id(container)
        if container_id is None:
            return None

        try:
            result = run_cmd(
                f'docker inspect --format "{{{{if .State.Health}}}}{{{{.State.Health.Status}}}}{{{{end}}}}" '
                f"{container_id}"
            )
        except CmdException:
            return None

        return result.stdout.strip() or None

    def wait_for(self, container: str, timeout: int = 60) -> None:
        """Waits for the container's own healthcheck, as declared in its compose file or image."""
        if not container:
            raise ValueError("container is required")

        if self.get_id(container) is None:
            raise DockerException(f"Container {container!r} not found")
        if self.get_health_status(container) is None:
            raise DockerException(f"Container {container!r} has no healthcheck declared")

        logger.debug(f"Waiting {timeout}s for {container!r} container to become healthy...")

        deadline = time.time() + timeout

        while time.time() < deadline:
            if self.get_health_status(container) == "healthy":
                return
            time.sleep(1)

        raise DockerException(f"Container {container!r} did not become healthy within {timeout}s")


class _NetworkManager(_Manager):
    def create(self, name: str, internal: bool = False) -> None:
        """An internal network has no route outside, so its members only reach each other."""
        if not name:
            raise ValueError("name is required")

        logger.debug(f"Creating {name!r} docker network...")

        try:
            run_cmd(f"docker network inspect {name}")
            return
        except CmdException:
            pass

        run_cmd(f"docker network create{' --internal' if internal else ''} {name}")


class Docker:
    """Compose operations need the compose files, so build a `Docker(*files)`.

    Container and network operations are file-independent: use the `docker` singleton.
    """

    def __init__(self, *files: str):
        self.files = list(files)

        self.compose = _ComposeManager(self)
        self.containers = _ContainerManager(self)
        self.networks = _NetworkManager(self)

    @property
    def file_flags(self) -> str:
        return " ".join(f"--file {file}" for file in self.files)

    @property
    def env_file_flags(self) -> str:
        return f"--env-file {ENV_FILE} --env-file {ENV_CUSTOM_FILE}" if os.path.isfile(ENV_CUSTOM_FILE) else ""


docker = Docker()
