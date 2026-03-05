import glob
import os

from library.authentik import AuthentikAPI
from library.docker import Docker
from library.service_deployer import ServiceDeployer


class Deploy(ServiceDeployer):
    def pre_deploy(self):
        self.register_hostname(
            self.envs.get("TRAEFIK_HOSTNAME"),
            self.envs.get("TRAEFIK_WHOAMI_HOSTNAME"),
        )
        Docker.create_network(self.envs.get("PROXY_NETWORK"))
        self._generate_tls_config()

    def post_deploy(self):
        api = AuthentikAPI.from_envs()
        api.wait_until_ready()

        self._configure_forward_auth(api)

    def _generate_tls_config(self):
        certs_dir = "./services/traefik/certs"
        config_file = "./services/traefik/config/tls.yml"

        self.logger.debug(f"Generating {config_file!r}...")

        lines = ["tls:", "  certificates:"]
        for cert_path in glob.glob(os.path.join(certs_dir, "*.crt")):
            cert_file = os.path.basename(cert_path)
            key_file = cert_file.replace(".crt", ".key")
            lines.append(f'    - certFile: "/certs/{cert_file}"')
            lines.append(f'      keyFile: "/certs/{key_file}"')

        with open(config_file, "w") as f:
            f.write("\n".join(lines) + "\n")

    def _configure_forward_auth(self, api: AuthentikAPI) -> None:
        self.logger.info("Configuring Traefik forward auth provider...")

        authentik_url = f"https://{self.envs.get('AUTHENTIK_HOSTNAME')}"

        provider = api.proxy_providers.ensure(
            "traefik-forward-auth-provider",
            mode="forward_domain",
            authorization_flow=api.flows.get_default_authorization_pk(throw=True),
            invalidation_flow=api.flows.get_default_invalidation_pk(throw=True),
            external_host=authentik_url,
            internal_host="http://authentik-server:9000",
            internal_host_ssl_validation=False,
            cookie_domain=self.envs.get("SERVICES_DOMAIN_NAME"),
            intercept_header_auth=True,
            access_token_validity="hours=24",
            refresh_token_validity="days=30",
            redirect_uris=[
                {
                    "matching_mode": "strict",
                    "url": f"{authentik_url}/outpost.goauthentik.io/callback?X-authentik-auth-callback=true",
                },
                {
                    "matching_mode": "strict",
                    "url": f"{authentik_url}?X-authentik-auth-callback=true",
                },
            ],
        )

        api.applications.ensure(
            "traefik-forward-auth",
            name="Traefik Forward Auth",
            provider=provider.pk,
            policy_engine_mode="any",
        )

        api.outposts.attach_provider(provider.pk)
