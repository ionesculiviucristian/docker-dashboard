import logging
import os

from rich.logging import RichHandler


def create_logger():
    logging.basicConfig(
        level=os.environ.get("LOG_LEVEL", "INFO"),
        format="%(message)s",
        datefmt="[%X]",
        handlers=[RichHandler(omit_repeated_times=False)],
    )
    return logging.getLogger("rich")


logger = create_logger()
