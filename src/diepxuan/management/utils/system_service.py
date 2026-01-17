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
from . import LOGDIR
from . import SERVICE_NAME

SYSTEMD_SERVICE = SERVICE_NAME
SYSTEMD_UNIT_PATH = f"/etc/systemd/system/{SYSTEMD_SERVICE}.service"

LAUNCHD_LABEL = f"com.diepxuan.{SERVICE_NAME}"
LAUNCHD_PLIST_PATH = f"/Library/LaunchDaemons/{LAUNCHD_LABEL}.plist"


def _ductnd_log_file():
    return f"{LOGDIR}/{SYSTEMD_SERVICE}.log"


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
        "Label": LAUNCHD_LABEL,
        "ProgramArguments": [
            # python_bin,
            ductn_bin,
            "service",  # tương ứng register_command d_service
        ],
        "RunAtLoad": True,
        "KeepAlive": True,
        "StandardOutPath": f"{LOGDIR}/{SYSTEMD_SERVICE}.log",
        "StandardErrorPath": f"{LOGDIR}/{SYSTEMD_SERVICE}.err",
        "ProcessType": "Background",
    }

    logging.info(f"Tạo LaunchDaemon plist {LAUNCHD_PLIST_PATH}")

    with open(LAUNCHD_PLIST_PATH, "wb") as f:
        plistlib.dump(plist, f)

    os.chmod(LAUNCHD_PLIST_PATH, 0o644)

    logging.info(f"Reload {SYSTEMD_SERVICE} launchd service")

    subprocess.run(
        ["launchctl", "bootout", "system", f"system/{LAUNCHD_LABEL}"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    subprocess.run(
        ["launchctl", "bootout", "system", LAUNCHD_PLIST_PATH],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    logging.info(f"Bootstrap {SYSTEMD_SERVICE} {LAUNCHD_PLIST_PATH}")
    subprocess.check_call(["launchctl", "bootstrap", "system", LAUNCHD_PLIST_PATH])
    subprocess.check_call(["launchctl", "enable", f"system/{LAUNCHD_LABEL}"])
    subprocess.check_call(["launchctl", "kickstart", "-k", f"system/{LAUNCHD_LABEL}"])

    logging.info(f"{SYSTEMD_SERVICE} service đã được cài đặt & khởi động")


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
    if not _is_root():
        logging.error("Cần quyền root")
        return

    try:
        _call_init_action("status")
    except Exception as e:
        logging.error(str(e))


@register_command
def d_service_watch():
    log_file = _ductnd_log_file()

    if not os.path.exists(log_file):
        logging.error(f"Log file not found: {log_file}")
        return

    logging.info(f"Watching ductnd log: {log_file}")
    logging.info("Press Ctrl+C to stop")

    try:
        subprocess.call(["tail", "-f", log_file])
    except KeyboardInterrupt:
        pass
