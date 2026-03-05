import os

from .env import envs
from .logger import logger
from .setup import CmdException, run_cmd

SERVICE_DIRS = ("./services", "./custom_services")
HOSTS_FILE = "/etc/hosts"


class ServiceDeployer:
    def __init__(self, name: str):
        if not name:
            raise ValueError("name is required")
        self.name = name
        self.envs = envs
        self.logger = logger

    def pre_deploy(self):
        pass

    def post_deploy(self):
        pass

    def get_compose_files(self) -> list[str]:
        for dir in SERVICE_DIRS:
            path = f"{dir}/{self.name}/docker-compose.yml"
            if os.path.isfile(path):
                return [path]
        return []

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
