import subprocess

from library.docker import Docker
from library.env import envs
from library.logger import logger
from library.setup import run_cmd


class Postgres:
    @staticmethod
    def wait_until_ready(timeout: int = 60) -> None:
        Docker.wait_for_container("postgres", f"pg_isready -U '{envs.get('POSTGRES_USER')}'", timeout)

    @staticmethod
    def create_database(database: str, username: str, password: str) -> None:
        if not database:
            raise ValueError("database is required")
        if not username:
            raise ValueError("username is required")
        if not password:
            raise ValueError("password is required")

        postgres_user = envs.get("POSTGRES_USER")

        logger.debug(f"Creating {database!r} PostgreSQL database for user {username!r}...")

        def pg_query(query: str) -> subprocess.CompletedProcess[str]:
            logger.debug(f"Running {query!r} query...")
            return run_cmd(
                f"docker compose exec postgres psql --username {postgres_user} "
                f'--tuples-only --no-align --command "{query}"'
            )

        result = pg_query(f"SELECT 1 FROM pg_roles WHERE rolname='{username}'")

        if result.stdout.strip() != "1":
            pg_query(f"CREATE USER {username} WITH PASSWORD '{password}'")

        result = pg_query(f"SELECT 1 FROM pg_database WHERE datname='{database}'")

        if result.stdout.strip() != "1":
            pg_query(f"CREATE DATABASE {database}")

        pg_query(f"GRANT ALL PRIVILEGES ON DATABASE {database} TO {username}")
