import sys
import distro  # pyright: ignore[reportMissingImports]
import logging

# Encoding Windows
sys.stdout.reconfigure(encoding="utf-8")

# --- Thiết lập Logging ---
PACKAGE_NAME = "ductn"
SERVICE_NAME = "ductnd"

# Nếu chạy bằng Python < 3.11, chèn future import vào compile hook
if sys.version_info < (3, 10):
    import builtins

    builtins.__annotations__ = True

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
from .system import _is_root

from rich.console import Console  # pyright: ignore[reportMissingImports]
from rich.table import Table  # pyright: ignore[reportMissingImports]

from . import command
from . import alias
from . import about
from . import vm
from . import addr
from . import host
from . import route
from . import service
from . import system
from . import system_os
from . import system_info
from . import system_service
from . import file
from . import env_detect
