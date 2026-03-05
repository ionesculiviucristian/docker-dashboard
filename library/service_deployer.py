import os
from typing import ClassVar

from .docker import docker
from .env import envs
from .logger import logger
from .setup import CmdException, run_cmd

SERVICE_DIRS = ("./services", "./custom_services")
HOSTS_FILE = "/etc/hosts"


class ServiceDeployer:
    generated_envs: ClassVar[tuple[str, ...]] = ()
    hostname_envs: ClassVar[tuple[str, ...]] = ()
    network_envs: ClassVar[tuple[str, ...]] = ()

    def __init__(self, name: str):
        if not name:
            raise ValueError("name is required")
        self.name = name
        self.envs = envs
        self.logger = logger

    def run_pre_deploy(self) -> None:
        """Prepares what the service declares, then runs its own pre_deploy."""
        if self.generated_envs:
            self.envs.generate(*self.generated_envs)
        if self.hostname_envs:
            self.register_hostname(*(self.envs.get(name) for name in self.hostname_envs))
        for name in self.network_envs:
            docker.networks.create(self.envs.get(name))

        self.pre_deploy()

    def pre_deploy(self):
        pass

    def post_deploy(self):
        pass

    def get_compose_files(self) -> list[str]:
        path = self.get_service_file("docker-compose.yml")
        return [path] if path else []

    def get_service_file(self, name: str) -> str | None:
        if not name:
            raise ValueError("name is required")

        for dir in SERVICE_DIRS:
            path = f"{dir}/{self.name}/{name}"
            if os.path.isfile(path):
                return path
        return None

    def register_hostname(self, *hostnames: str) -> None:
        if not hostnames:
            raise ValueError("hostnames is required")

        for hostname in hostnames:
            if not hostname:
                raise ValueError("hostname is required")

            self.logger.debug(f"Registering {hostname!r} service hostname...")

            try:
                run_cmd(f"grep --quiet {hostname} {HOSTS_FILE}")
                continue
            except CmdException:
                pass

            run_cmd(f"echo '127.0.0.1 {hostname}' | sudo tee --append {HOSTS_FILE}")
