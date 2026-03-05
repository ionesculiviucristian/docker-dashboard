from library.docker import docker
from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    generated_envs = ("OLLAMA_OPEN_WEBUI_WEBUI_SECRET_KEY",)
    hostname_envs = ("OLLAMA_OPEN_WEBUI_HOSTNAME",)
    network_envs = ("OLLAMA_NETWORK",)

    def get_compose_files(self) -> list[str]:
        return super().get_compose_files() + [self.envs.get("OLLAMA_RUNTIME")]

    def post_deploy(self):
        self._setup_model()

    def _setup_model(self):
        if "gpu" not in self.envs.get("OLLAMA_RUNTIME"):
            self.logger.warning("ollama is using CPU runtime mode, skipping")
            return

        docker.containers.wait_for("ollama", 600)

        model = self.envs.get("OLLAMA_MODEL")
        self.logger.info(f"Pulling {model!r} model...")
        docker.containers.exec("ollama", f"ollama pull {model}")
