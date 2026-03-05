import os

from library.service_deployer import ServiceDeployer
from library.setup import run_cmd
from services.ntfy.service import Ntfy


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        self.register_hostname(self.envs.get("WHATSUPDOCKER_HOSTNAME"))

    def post_deploy(self):
        topic = self.envs.get("WHATSUPDOCKER_WUD_TRIGGER_NTFY_LOCAL_TOPIC")

        Ntfy.wait_until_ready()
        Ntfy.create_user(self.envs.get("NTFY_WUD_USER"), self.envs.get("NTFY_WUD_PASSWORD"), topic, "write-only")
        Ntfy.create_user(self.envs.get("NTFY_SUBSCRIBE_USER"), self.envs.get("NTFY_SUBSCRIBE_PASSWORD"), topic, "read-only")

        self._setup_systemd_service()

    def _setup_systemd_service(self):
        service_name = "ntfy-subscribe"
        service_dir = os.path.expanduser("~/.config/systemd/user")
        service_file = os.path.join(service_dir, f"{service_name}.service")
        os.makedirs(service_dir, exist_ok=True)

        env_vars = (
            "${NTFY_SUBSCRIBE_USER} ${NTFY_SUBSCRIBE_PASSWORD} "
            "${NTFY_HOSTNAME} ${WHATSUPDOCKER_WUD_TRIGGER_NTFY_LOCAL_TOPIC}"
        )
        run_cmd(f"envsubst '{env_vars}' <./services/whatsupdocker/setup/ntfy-subscribe.service >\"{service_file}\"")

        run_cmd("systemctl --user daemon-reload")
        run_cmd(f"systemctl --user enable --now {service_name}")
        run_cmd(f"systemctl --user restart {service_name}")
        self.logger.info(f"systemd service {service_name!r} enabled and started")
