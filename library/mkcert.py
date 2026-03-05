from .env import envs
from .logger import logger
from .setup import run_cmd

CERTS_DIR = "./services/traefik/certs"
CA_CERTIFICATE_NAME = "rootCA.pem"


class MkcertException(Exception):
    pass


class Mkcert:
    @staticmethod
    def install_ca() -> None:
        logger.debug("Installing local CA certificate...")
        run_cmd("mkcert -install")

        caroot = run_cmd("mkcert -CAROOT").stdout.strip()
        if not caroot:
            raise MkcertException("mkcert CAROOT is empty")

        # Services that talk to each other over https mount this CA to verify the certificates.
        envs.set("CA_CERTIFICATE_HOST_FILE", f"{caroot}/{CA_CERTIFICATE_NAME}", custom=True)

    @staticmethod
    def create_certificate(domain: str) -> None:
        if not domain:
            raise ValueError("domain is required")

        logger.debug(f"Creating {domain!r} domain certificate...")

        run_cmd(f"mkcert -cert-file {CERTS_DIR}/{domain}.crt -key-file {CERTS_DIR}/{domain}.key *.{domain} {domain}")
