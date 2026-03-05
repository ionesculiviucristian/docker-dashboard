from library.docker import Docker
from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    def get_compose_files(self) -> list[str]:
        return super().get_compose_files() + [self.envs.get("OLLAMA_RUNTIME")]

    def pre_deploy(self):
        self.envs.generate("OLLAMA_OPEN_WEBUI_WEBUI_SECRET_KEY")
        self.register_hostname(self.envs.get("OLLAMA_OPEN_WEBUI_HOSTNAME"))
        Docker.create_network(self.envs.get("OLLAMA_NETWORK"))

    def post_deploy(self):
        self._setup_model()

    def _setup_model(self):
        if "gpu" not in self.envs.get("OLLAMA_RUNTIME"):
            self.logger.warning("ollama is using CPU runtime mode, skipping")
            return

        Docker.wait_for_container("ollama", "ollama list", 600)

        model = self.envs.get("OLLAMA_MODEL")
        self.logger.info(f"Pulling {model!r} model...")
        Docker.exec("ollama", f"ollama pull {model}")
