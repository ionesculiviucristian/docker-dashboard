import time

from library.docker import docker
from library.service_deployer import ServiceDeployer

CONFIG_FILE = "/etc/prometheus/prometheus.yml"
RELOAD_METRIC = "prometheus_config_last_reload_success_timestamp_seconds"
RELOAD_TIMEOUT = 30


class PrometheusException(Exception):
    pass


class Deploy(ServiceDeployer):
    hostname_envs = ("PROMETHEUS_HOSTNAME",)
    network_envs = ("PROMETHEUS_NETWORK",)

    def post_deploy(self):
        self._reload()

    def _reload(self) -> None:
        """Applies configuration changes, as Prometheus reads its file only when told to."""
        docker.containers.wait_for("prometheus")

        self.logger.info("Reloading Prometheus configuration...")

        docker.containers.exec("prometheus", f"promtool check config {CONFIG_FILE}")

        reloaded_at = self._get_reload_timestamp()
        docker.containers.send_signal("prometheus", "HUP")

        deadline = time.time() + RELOAD_TIMEOUT
        while time.time() < deadline:
            if self._get_reload_timestamp() > reloaded_at:
                return
            time.sleep(1)

        # A rejected configuration leaves Prometheus running happily on the previous one.
        raise PrometheusException(f"Prometheus did not reload its configuration within {RELOAD_TIMEOUT}s")

    def _get_reload_timestamp(self) -> float:
        result = docker.containers.exec("prometheus", "wget --quiet --output-document - http://localhost:9090/metrics")

        for line in result.stdout.splitlines():
            if line.startswith(RELOAD_METRIC):
                return float(line.split()[1])

        raise PrometheusException(f"Metric {RELOAD_METRIC!r} not found")
