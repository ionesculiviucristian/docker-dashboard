from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    hostname_envs = ("POSTGRES_PGADMIN4_HOSTNAME",)
    network_envs = ("POSTGRES_NETWORK",)
