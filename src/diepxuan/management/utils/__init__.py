import sys
import distro
import logging

# --- Thiết lập Logging ---
from ductn import PACKAGE_NAME, SERVICE_NAME

# Ghi log ra stdout/stderr, systemd sẽ tự động bắt và chuyển vào journald
logging.basicConfig(
    level=logging.INFO,
    format=f"%(asctime)s {PACKAGE_NAME} {SERVICE_NAME}: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    stream=sys.stdout,
)

from . import registry
from .registry import COMMANDS
from .registry import register_command

from rich.console import Console
from rich.table import Table

from . import host
from . import addr
from . import vm
from . import about
from . import route
from . import service
from . import system
from . import system_info
