#!/usr/bin/env python3

import logging
import os
import platform
import subprocess
import sys
import plistlib
import shutil

from .system import _is_root
from .about import _version

from .registry import register_command
from . import distro
from . import service

SYSTEMD_SERVICE = "ductnd"
SYSTEMD_UNIT_PATH = f"/etc/systemd/system/{SYSTEMD_SERVICE}.service"

LAUNCHD_LABEL = "com.diepxuan.ductnd"
LAUNCHD_PLIST_PATH = f"/Library/LaunchDaemons/{LAUNCHD_LABEL}.plist"


def _call_init_action(action, init=None):
    """
    Gọi action theo init system.
    Nếu init=None → tự detect bằng _get_init_system()
    """
    if init is None:
        init = _get_init_system()
    fn_name = f"_{init}_{action}"
    fn = globals().get(fn_name)

    if not fn:
        raise RuntimeError(f"Unsupported init/action: {fn_name}")

    return fn()


@register_command
def d_service_install():
    """
    Kiểm tra, cài đặt & khởi động ductnd service trên macOS (launchd)
    """
    if sys.platform != "darwin":
        logging.error("service install chỉ dùng cho macOS")
        return

    if not _is_root():
        logging.error("Cần chạy với quyền root (sudo)")
        return

    python_bin = sys.executable
    ductn_bin = shutil.which("ductn")

    if ductn_bin:
        ductn_bin = os.path.realpath(ductn_bin)
    else:
        ductn_bin = os.path.realpath(sys.argv[0])

    plist = {
        "Label": LAUNCHD_PLIST_PATH,
        "ProgramArguments": [
            python_bin,
            ductn_bin,
            "service",  # tương ứng register_command d_service
        ],
        "RunAtLoad": True,
        "KeepAlive": True,
        "StandardOutPath": "/var/log/{SYSTEMD_SERVICE}.log",
        "StandardErrorPath": "/var/log/{SYSTEMD_SERVICE}.err",
        "ProcessType": "Background",
    }

    logging.info("Tạo LaunchDaemon plist...")

    with open(LAUNCHD_PLIST_PATH, "wb") as f:
        plistlib.dump(plist, f)

    os.chmod(LAUNCHD_PLIST_PATH, 0o644)

    logging.info("Reload launchd service")

    subprocess.run(
        ["launchctl", "bootout", "system", f"system/{LAUNCHD_LABEL}"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    subprocess.check_call(["launchctl", "bootstrap", "system", LAUNCHD_PLIST_PATH])
    subprocess.check_call(["launchctl", "enable", f"system/{LAUNCHD_LABEL}"])
    subprocess.check_call(["launchctl", "kickstart", "-k", f"system/{LAUNCHD_LABEL}"])

    logging.info("{SYSTEMD_SERVICE} service đã được cài đặt & khởi động")


def _get_init_system():
    if sys.platform == "darwin":
        return "launchd"
    if os.path.exists("/bin/systemctl") or os.path.exists("/usr/bin/systemctl"):
        return "systemd"
    return "unknown"


def _ductn_binary():
    binPath = shutil.which("ductn")
    if binPath:
        binPath = os.path.realpath(binPath)
        logging.info(f"Using ductn from PATH: {binPath}")
        return binPath

    binPath = os.path.realpath(sys.argv[0])
    logging.info(f"Using current script as ductn: {binPath}")
    return binPath


def _systemd_start():
    subprocess.check_call(["systemctl", "start", SYSTEMD_SERVICE])


def _systemd_stop():
    subprocess.check_call(["systemctl", "stop", SYSTEMD_SERVICE])


def _systemd_restart():
    subprocess.check_call(["systemctl", "restart", SYSTEMD_SERVICE])


def _systemd_status():
    result = subprocess.run(
        ["systemctl", "is-active", SYSTEMD_SERVICE],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return result.stdout.strip()


def _launchd_start():
    subprocess.run(
        ["launchctl", "bootstrap", "system", LAUNCHD_PLIST_PATH],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    subprocess.check_call(["launchctl", "kickstart", "-k", f"system/{LAUNCHD_LABEL}"])


def _launchd_stop():
    subprocess.run(
        ["launchctl", "bootout", "system", f"system/{LAUNCHD_LABEL}"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def _launchd_restart():
    _launchd_stop()
    _launchd_start()


def _launchd_status():
    result = subprocess.run(
        ["launchctl", "list"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return "running" if LAUNCHD_LABEL in result.stdout else "stopped"


@register_command
def d_service_start():
    if not _is_root():
        logging.error("Cần quyền root")
        return

    try:
        _call_init_action("start")
    except Exception as e:
        logging.error(str(e))


@register_command
def d_service_stop():
    if not _is_root():
        logging.error("Cần quyền root")
        return

    try:
        _call_init_action("stop")
    except Exception as e:
        logging.error(str(e))


@register_command
def d_service_restart():
    if not _is_root():
        logging.error("Cần quyền root")
        return

    try:
        _call_init_action("restart")
    except Exception as e:
        logging.error(str(e))


@register_command
def d_service_status():
    init = _get_init_system()

    try:
        _call_init_action("status")
    except Exception as e:
        logging.error(str(e))
