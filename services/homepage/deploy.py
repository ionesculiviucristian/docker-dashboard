import os

import yaml

from library.config import config
from library.service_deployer import ServiceDeployer

SERVICES_FILE = "./services/homepage/config/services.yaml"
BOOKMARKS_FILE = "./services/homepage/config/bookmarks.yaml"


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        self.register_hostname(self.envs.get("HOMEPAGE_HOSTNAME"))
        self._ensure_bookmarks_file()
        self._generate_services_config()

    def _ensure_bookmarks_file(self):
        self.logger.debug(f"Creating {BOOKMARKS_FILE!r}...")
        if os.path.isfile(BOOKMARKS_FILE):
            return
        open(BOOKMARKS_FILE, "w").close()

    def _generate_services_config(self):
        self.logger.debug(f"Generating {SERVICES_FILE!r}...")
        entries: dict[str, dict[str, object]] = {}

        for service in config.services:
            for base in ("./services", "./custom_services"):
                path = f"{base}/{service}/service.yml"
                if not os.path.isfile(path):
                    continue
                with open(path, encoding="utf8") as stream:
                    data: dict[str, list[dict[str, object]]] = yaml.safe_load(stream) or {}
                for entry in data.get("homepage") or []:
                    name = entry.pop("name")
                    if isinstance(name, str):
                        entries[name] = entry
                break

        sorted_entries = [{name: entries[name]} for name in sorted(entries, key=str.lower)]
        output = [{"Services": sorted_entries}]

        with open(SERVICES_FILE, "w", encoding="utf8") as stream:
            yaml.safe_dump(output, stream, sort_keys=False, default_flow_style=False, width=4096)
