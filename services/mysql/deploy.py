from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    hostname_envs = ("MYSQL_PHPMYADMIN_HOSTNAME",)
    network_envs = ("MYSQL_NETWORK",)
