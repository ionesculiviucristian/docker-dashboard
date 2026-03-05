from library.docker import Docker
from library.env import envs
from library.logger import logger
from library.setup import run_cmd


class Ntfy:
    @staticmethod
    def wait_until_ready(timeout: int = 60) -> None:
        port = envs.get("NTFY_HOSTNAME_PORT")
        Docker.wait_for_container("ntfy", f"wget -q --tries=1 http://127.0.0.1:{port}/v1/health -O /dev/null", timeout)

    @staticmethod
    def create_user(username: str, password: str, topic: str, access: str) -> None:
        if not username:
            raise ValueError("username is required")
        if not password:
            raise ValueError("password is required")
        if not topic:
            raise ValueError("topic is required")
        if not access:
            raise ValueError("access is required")

        result = Docker.exec("ntfy", "ntfy user list")
        if username in result.stdout:
            logger.info(f"Updating password for existing ntfy user {username!r}...")
            run_cmd(f'docker compose exec -T -e NTFY_PASSWORD="{password}" ntfy ntfy user change-pass "{username}"')
        else:
            logger.info(f"Creating ntfy user {username!r}...")
            run_cmd(f'docker compose exec -T -e NTFY_PASSWORD="{password}" ntfy ntfy user add --ignore-exists "{username}"')
            logger.info(f"ntfy user {username!r} created")

        run_cmd(f'docker compose exec -T ntfy ntfy access "{username}" "{topic}" "{access}"')
