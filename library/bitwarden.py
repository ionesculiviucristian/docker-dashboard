from .logger import logger
from .setup import run_cmd

HOMEPAGE_BOOKMARKS_FILE = "./services/homepage/config/bookmarks.yaml"


def import_data(email: str) -> None:
    if not email:
        raise ValueError("email is required")

    logger.info(f"Importing bitwarden data for {email!r}...")

    result = run_cmd(f"bw login {email} --method 0 --raw")
    bw_session = f"BW_SESSION={result.stdout}"

    try:
        _import_homepage_data(bw_session)
    finally:
        run_cmd(f"{bw_session} bw logout")


def _import_homepage_data(bw_session: str) -> None:
    result = run_cmd(
        f'{bw_session} bw get attachment "bookmarks.yaml" --itemid "Docker dashboard bookmarks" --raw', text=False
    )

    with open(HOMEPAGE_BOOKMARKS_FILE, "wb") as f:
        f.write(result.stdout)

    run_cmd("docker compose restart homepage")
