from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    hostname_envs = ("CADVISOR_HOSTNAME",)
