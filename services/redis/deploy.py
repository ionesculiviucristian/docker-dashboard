from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    hostname_envs = ("REDIS_HOSTNAME",)
    network_envs = ("REDIS_NETWORK",)
