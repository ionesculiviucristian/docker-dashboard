from .logger import logger
from .setup import run_cmd

CERTS_DIR = "./services/traefik/certs"


class Mkcert:
    @staticmethod
    def install_ca() -> None:
        logger.debug("Installing local CA certificate...")
        run_cmd("mkcert -install")

    @staticmethod
    def create_certificate(domain: str) -> None:
        if not domain:
            raise ValueError("domain is required")

        logger.debug(f"Creating {domain!r} domain certificate...")

        run_cmd(f"mkcert -cert-file {CERTS_DIR}/{domain}.crt -key-file {CERTS_DIR}/{domain}.key *.{domain} {domain}")
