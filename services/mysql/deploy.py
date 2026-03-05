from library.docker import Docker
from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        self.register_hostname(self.envs.get("MYSQL_PHPMYADMIN_HOSTNAME"))
        Docker.create_network(self.envs.get("MYSQL_NETWORK"))
