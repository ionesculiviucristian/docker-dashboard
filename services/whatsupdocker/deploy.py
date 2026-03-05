import os

from library.authentik import AuthentikAPI
from library.docker import Docker
from library.service_deployer import ServiceDeployer
from library.setup import run_cmd
from services.ntfy.service import Ntfy


class Deploy(ServiceDeployer):
    hostname_envs = ("WHATSUPDOCKER_HOSTNAME",)

    def post_deploy(self):
        api = AuthentikAPI()
        api.wait()

        client_secret = self._configure_oidc(api)
        if client_secret != self.envs.get("WHATSUPDOCKER_OIDC_CLIENT_SECRET"):
            self.envs.set("WHATSUPDOCKER_OIDC_CLIENT_SECRET", client_secret, custom=True)
            Docker(*self.get_compose_files()).compose.up(recreate=True)

        topic = self.envs.get("WHATSUPDOCKER_WUD_TRIGGER_NTFY_LOCAL_TOPIC")

        Ntfy.wait()
        Ntfy.create_user(self.envs.get("NTFY_WUD_USER"), self.envs.get("NTFY_WUD_PASSWORD"), topic, "write-only")
        Ntfy.create_user(
            self.envs.get("NTFY_SUBSCRIBE_USER"), self.envs.get("NTFY_SUBSCRIBE_PASSWORD"), topic, "read-only"
        )

        self._setup_systemd_service()

    def _configure_oidc(self, api: AuthentikAPI) -> str:
        self.logger.info("Configuring OIDC...")

        managed_scopes = [
            api.scopes.get_managed_pk(managed, throw=True)
            for managed in (
                "goauthentik.io/providers/oauth2/scope-openid",
                "goauthentik.io/providers/oauth2/scope-email",
                "goauthentik.io/providers/oauth2/scope-profile",
            )
        ]

        provider = api.oauth2_providers.ensure(
            "whatsupdocker-provider",
            client_type="confidential",
            client_id=self.envs.get("WHATSUPDOCKER_OIDC_CLIENT_ID"),
            authorization_flow=api.flows.get_default_authorization_pk(throw=True),
            invalidation_flow=api.flows.get_default_invalidation_pk(throw=True),
            signing_key=api.certificates.get_default_signing_key_pk(throw=True),
            property_mappings=managed_scopes,
            redirect_uris=[
                {
                    "matching_mode": "strict",
                    "url": f"https://{self.envs.get('WHATSUPDOCKER_HOSTNAME')}/auth/oidc/authentik/cb",
                }
            ],
            access_token_validity="hours=24",
            refresh_token_validity="days=30",
        )

        api.applications.ensure(
            "whatsupdocker",
            name="What's up Docker?",
            provider=provider.pk,
            meta_launch_url=f"https://{self.envs.get('WHATSUPDOCKER_HOSTNAME')}",
            policy_engine_mode="any",
        )

        return provider.client_secret

    def _setup_systemd_service(self):
        service_name = "ntfy-subscribe"
        service_dir = os.path.expanduser("~/.config/systemd/user")
        service_file = os.path.join(service_dir, f"{service_name}.service")
        os.makedirs(service_dir, exist_ok=True)

        env_vars = (
            "${NTFY_SUBSCRIBE_USER} ${NTFY_SUBSCRIBE_PASSWORD} "
            "${NTFY_HOSTNAME} ${WHATSUPDOCKER_WUD_TRIGGER_NTFY_LOCAL_TOPIC}"
        )
        run_cmd(f"envsubst '{env_vars}' <./services/whatsupdocker/setup/ntfy-subscribe.service >\"{service_file}\"")

        run_cmd("systemctl --user daemon-reload")
        run_cmd(f"systemctl --user enable --now {service_name}")
        run_cmd(f"systemctl --user restart {service_name}")
        self.logger.info(f"systemd service {service_name!r} enabled and started")
