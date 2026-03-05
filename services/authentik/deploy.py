from library.authentik import AuthentikAPI
from library.service_deployer import ServiceDeployer
from services.postgres.service import Postgres


class Deploy(ServiceDeployer):
    generated_envs = ("AUTHENTIK_BOOTSTRAP_TOKEN", "AUTHENTIK_SECRET_KEY")
    hostname_envs = ("AUTHENTIK_HOSTNAME",)
    network_envs = ("AUTHENTIK_NETWORK",)

    def post_deploy(self):
        Postgres.wait()
        Postgres.create_database(
            self.envs.get("AUTHENTIK_POSTGRES_DB"),
            self.envs.get("AUTHENTIK_POSTGRES_USER"),
            self.envs.get("AUTHENTIK_POSTGRES_USER_PASSWORD"),
        )

        api = AuthentikAPI()
        api.wait()

        api.flows.ensure_default_authorization()
        api.flows.ensure_default_invalidation()
