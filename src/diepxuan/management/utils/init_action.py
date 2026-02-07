import os, sys
from . import registry


def _get_init_system():
    if sys.platform == "darwin":
        return "launchd"
    if os.path.exists("/bin/systemctl") or os.path.exists("/usr/bin/systemctl"):
        return "systemd"
    return "unknown"


def call_init_action(action, init=None):
    """
    Gọi action theo init system.
    Nếu init=None → tự detect bằng _get_init_system()
    """
    return registry.call_init_action(action, init)


def register_init_action(*actions):
    """
    Decorator để đăng ký action theo init system.
    Tên action được suy ra từ tên hàm: _{init}_{action}
    """
    return registry.register_init_action(*actions)
