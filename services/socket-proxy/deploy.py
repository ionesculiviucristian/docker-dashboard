from library.docker import docker
from library.service_deployer import ServiceDeployer
from library.setup import run_cmd


class SocketProxyException(Exception):
    pass


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        # Clients reach the proxy only through this network, which leads nowhere else.
        docker.networks.create(self.envs.get("SOCKET_PROXY_NETWORK"), internal=True)

        self._set_docker_group()

    def _set_docker_group(self) -> None:
        """The proxy runs as nobody, so it needs the docker group to read the socket it forwards to."""
        group_id = run_cmd("getent group docker | cut --delimiter : --fields 3").stdout.strip()
        if not group_id:
            raise SocketProxyException("Docker group not found")

        self.envs.set("DOCKER_GID", group_id, custom=True)
