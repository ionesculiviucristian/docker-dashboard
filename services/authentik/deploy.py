from library.authentik import AuthentikAPI
from library.docker import Docker
from library.service_deployer import ServiceDeployer
from services.postgres.service import Postgres


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        self.envs.generate("AUTHENTIK_BOOTSTRAP_TOKEN", "AUTHENTIK_SECRET_KEY")
        self.register_hostname(self.envs.get("AUTHENTIK_HOSTNAME"))
        Docker.create_network(self.envs.get("AUTHENTIK_NETWORK"))

    def post_deploy(self):
        Postgres.wait_until_ready()
        Postgres.create_database(
            self.envs.get("AUTHENTIK_POSTGRES_DB"),
            self.envs.get("AUTHENTIK_POSTGRES_USER"),
            self.envs.get("AUTHENTIK_POSTGRES_USER_PASSWORD"),
        )

        api = AuthentikAPI.from_envs()
        api.wait_until_ready()

        api.flows.ensure_default_authorization()
        api.flows.ensure_default_invalidation()
