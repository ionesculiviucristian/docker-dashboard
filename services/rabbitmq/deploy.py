from library.docker import Docker
from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        self.register_hostname(self.envs.get("RABBITMQ_HOSTNAME"))
        Docker.create_network(self.envs.get("RABBITMQ_NETWORK"))

    def post_deploy(self):
        Docker.wait_for_container("rabbitmq", "rabbitmq-diagnostics ping")

        self.logger.info("Enabling RabbitMQ plugins...")
        Docker.exec("rabbitmq", "rabbitmq-plugins enable rabbitmq_prometheus")
