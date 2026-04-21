import subprocess
import sys
import re

from . import register_command


@register_command
def d_interface_default():
    """Trả về interface Mac Dinh."""
    print(get_default_interface())


def get_default_interface():
    """Trả về interface Mac Dinh."""
    if sys.platform == "darwin":
        out = subprocess.check_output(
            ["route", "get", "default"], stderr=subprocess.DEVNULL, text=True
        )
        m = re.search(r"interface:\s+(\S+)", out)
        return m.group(1) if m else None

    else:  # Linux
        out = subprocess.check_output(
            ["ip", "route", "show", "default"], stderr=subprocess.DEVNULL, text=True
        )
        m = re.search(r"dev\s+(\S+)", out)
        return m.group(1) if m else None


import subprocess


@register_command
def d_interface_service():
    """Trả về interface Mac Dinh."""
    print(get_active_service())


def get_active_service():
    # Lấy interface default
    iface = subprocess.check_output(["route", "get", "default"], text=True)
    iface = next(
        line.split(":")[1].strip()
        for line in iface.splitlines()
        if line.strip().startswith("interface:")
    )

    # Map interface → service name
    services = subprocess.check_output(
        ["networksetup", "-listallhardwareports"], text=True
    )

    current_service = None
    current_device = None

    for line in services.splitlines():
        if line.startswith("Hardware Port:"):
            current_service = line.split(":", 1)[1].strip()
        elif line.startswith("Device:"):
            current_device = line.split(":", 1)[1].strip()
            if current_device == iface:
                return current_service

    return None
