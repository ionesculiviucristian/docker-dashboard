from library.authentik import AuthentikAPI
from library.docker import Docker
from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        self.envs.generate("GRAFANA_GF_SECURITY_ADMIN_PASSWORD")
        self.register_hostname(
            self.envs.get("GRAFANA_HOSTNAME"),
            self.envs.get("GRAFANA_ALLOY_HOSTNAME"),
        )
        Docker.create_network(self.envs.get("GRAFANA_NETWORK"))

    def post_deploy(self):
        api = AuthentikAPI.from_envs()
        api.wait_until_ready()

        client_secret = self._configure_oidc(api)
        if client_secret == self.envs.get("GRAFANA_GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET"):
            self.logger.debug("OIDC already configured, skipping restart")
            return

        self.envs.set("GRAFANA_GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET", client_secret, custom=True)
        Docker.start_containers(self.get_compose_files(), recreate=True)

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
            "grafana-provider",
            client_type="confidential",
            client_id=self.envs.get("GRAFANA_GF_AUTH_GENERIC_OAUTH_CLIENT_ID"),
            authorization_flow=api.flows.get_default_authorization_pk(throw=True),
            invalidation_flow=api.flows.get_default_invalidation_pk(throw=True),
            signing_key=api.certificates.get_default_signing_key_pk(throw=True),
            property_mappings=managed_scopes,
            redirect_uris=[
                {
                    "matching_mode": "strict",
                    "url": f"https://{self.envs.get('GRAFANA_HOSTNAME')}/login/generic_oauth",
                }
            ],
            access_token_validity="hours=24",
            refresh_token_validity="days=30",
        )

        api.applications.ensure(
            "grafana",
            name="Grafana",
            provider=provider.pk,
            meta_launch_url=f"https://{self.envs.get('GRAFANA_HOSTNAME')}",
            policy_engine_mode="any",
        )

        return provider.client_secret
