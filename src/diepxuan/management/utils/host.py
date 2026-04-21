#!/usr/bin/env python3
# shellcheck disable=SC2034,SC2154,SC1090,SC1091

import logging
import socket
import sys
from .registry import register_command
from .init_action import call_init_action, register_init_action
import subprocess

DEFAULT_DOMAIN = "diepxuan.corp"


@register_init_action
def _launchd_host_name():
    try:
        name = socket.gethostname().split(".", 1)[0]
        if not name:
            try:
                name = (
                    subprocess.check_output(
                        ["scutil", "--get", "ComputerName"],
                        text=True,
                    )
                    .decode()
                    .strip()
                )
            except Exception:
                pass

        if not name:
            name = "unknown-host"

        return name
    except Exception as e:
        logging.error(f"Không thể lấy hostname: {e}")
        return "unknown-host"


@register_init_action
def _systemd_host_name():
    try:
        return socket.gethostname().split(".", 1)[0]
    except Exception as e:
        logging.error(f"Không thể lấy hostname: {e}")
        return "unknown-host"


def _host_name():
    """Trả về tên hostname ngắn của máy."""
    return call_init_action("host_name")


@register_command
def d_host_name():
    """In tên hostname ngắn của máy."""
    print(_host_name())


def _host_domain():
    """
    Trả về tên domain của máy.
    Trả về chuỗi rỗng nếu không thể xác định (ví dụ: máy không thuộc domain nào).
    """
    try:
        fullname = socket.getfqdn()
        if ":" or "ip6.arpa" in fullname:  # IPv6
            fullname = DEFAULT_DOMAIN

        hostname = socket.gethostname()
        # Kiểm tra xem FQDN có chứa hostname không
        if fullname.startswith(hostname + ".") and len(fullname) > len(hostname):
            # Lấy phần còn lại sau hostname và dấu chấm
            return fullname[len(hostname) + 1 :]

        return DEFAULT_DOMAIN  # Trả về DEFAULT nếu không có domain
    except Exception as e:
        # print(f"Không thể lấy domain name: {e}")
        return DEFAULT_DOMAIN


@register_command
def d_host_domain():
    """In tên domain của máy."""
    print(_host_domain())


@register_init_action
def _launchd_host_fullname():
    return _host_name() + "." + _host_domain()


@register_init_action
def _systemd_host_fullname():
    try:
        return socket.getfqdn()
    except Exception as e:
        return _host_name() + "." + _host_domain()


def _host_fullname():
    """Trả về tên hostname đầy đủ (FQDN) của máy."""
    return call_init_action("host_fullname")


@register_command
def d_host_fullname():
    """In tên hostname đầy đủ (FQDN) của máy."""
    print(_host_fullname())
