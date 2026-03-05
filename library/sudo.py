import atexit
import getpass
import signal
import subprocess
import sys

from .logger import logger

SUDOERS_FILE = "/etc/sudoers.d/docker-dashboard"
_installed = False


def acquire() -> None:
    global _installed
    if _installed:
        return

    user = getpass.getuser()
    content = f"{user} ALL=(ALL) NOPASSWD: ALL\n"

    logger.debug(f"Installing temporary sudoers file at {SUDOERS_FILE}...")
    subprocess.run(
        ["sudo", "tee", SUDOERS_FILE],
        input=content,
        text=True,
        check=True,
        stdout=subprocess.DEVNULL,
    )
    subprocess.run(["sudo", "chmod", "0440", SUDOERS_FILE], check=True)

    _installed = True
    atexit.register(release)
    for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
        signal.signal(sig, _on_signal)


def release() -> None:
    global _installed
    if not _installed:
        return
    _installed = False
    logger.debug("Removing temporary sudoers file...")
    subprocess.run(["sudo", "rm", "--force", SUDOERS_FILE], check=False)


def _on_signal(signum: int, _frame: object) -> None:
    release()
    sys.exit(128 + signum)
