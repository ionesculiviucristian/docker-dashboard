import subprocess
from typing import Literal, overload

from .logger import logger

REQUIRED_PACKAGES = ["docker", "mkcert"]


class CmdException(Exception):
    pass


@overload
def run_cmd(cmd: str) -> subprocess.CompletedProcess[str]: ...
@overload
def run_cmd(cmd: str, text: Literal[True]) -> subprocess.CompletedProcess[str]: ...
@overload
def run_cmd(cmd: str, text: Literal[False]) -> subprocess.CompletedProcess[bytes]: ...
def run_cmd(cmd: str, text: bool = True) -> subprocess.CompletedProcess[str] | subprocess.CompletedProcess[bytes]:
    if not cmd:
        raise ValueError("cmd is required")

    logger.debug(f"Running {cmd!r} command...")

    result = subprocess.run(cmd, text=text, capture_output=True, shell=True)
    if result.returncode:
        raise CmdException(
            f"Command {cmd!r} failed (code {result.returncode}): {(result.stderr or result.stdout).strip()}"
        )
    return result


def check_requirements() -> None:
    logger.debug("Checking requirements...")
    for package in REQUIRED_PACKAGES:
        run_cmd(f"which {package}")
