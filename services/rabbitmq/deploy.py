from library.docker import docker
from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    hostname_envs = ("RABBITMQ_HOSTNAME",)
    network_envs = ("RABBITMQ_NETWORK",)

    def post_deploy(self):
        docker.containers.wait_for("rabbitmq")

        self.logger.info("Enabling RabbitMQ plugins...")
        docker.containers.exec("rabbitmq", "rabbitmq-plugins enable rabbitmq_prometheus")
