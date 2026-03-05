from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    hostname_envs = ("NTFY_HOSTNAME",)
