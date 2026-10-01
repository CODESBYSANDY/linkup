"""Application logging configuration.

Provides structured, readable logs across the application with standard
timestamp, log level, module origin, and messages.
"""

import logging
import sys
from app.core.config import settings


def setup_logging() -> None:
    """Configure the root logger and standard library logging handlers."""
    log_level = logging.DEBUG if settings.DEBUG else logging.INFO
    log_format = "%(asctime)s | %(levelname)-8s | %(name)s:%(lineno)d - %(message)s"
    date_format = "%Y-%m-%d %H:%M:%S"

    # Configure root logger
    logging.basicConfig(
        level=log_level,
        format=log_format,
        datefmt=date_format,
        handlers=[logging.StreamHandler(sys.stdout)],
        force=True,
    )

    # Set third-party logger levels to prevent excessive noise
    logging.getLogger("uvicorn.access").setLevel(logging.INFO)
    logging.getLogger("uvicorn.error").setLevel(logging.INFO)


logger = logging.getLogger("linkup")
