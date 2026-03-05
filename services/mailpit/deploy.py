from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    hostname_envs = ("MAILPIT_HOSTNAME",)
    network_envs = ("MAILPIT_NETWORK",)
