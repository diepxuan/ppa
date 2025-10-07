#!/usr/bin/env python3
# shellcheck disable=SC2034,SC2154,SC1090,SC1091

import logging
import socket
import sys
from .registry import register_command


def _host_name():
    """Trả về tên hostname ngắn của máy."""
    try:
        return socket.gethostname()
    except Exception as e:
        logging.error(f"Không thể lấy hostname: {e}")
        return "unknown-host"


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
        hostname = socket.gethostname()

        # Kiểm tra xem FQDN có chứa hostname không
        if fullname.startswith(hostname + ".") and len(fullname) > len(hostname):
            # Lấy phần còn lại sau hostname và dấu chấm
            return fullname[len(hostname) + 1 :]

        # Một cách khác để thử nếu ở trên thất bại
        parts = fullname.split(".", 1)
        if len(parts) > 1:
            return parts[1]

        return ""  # Trả về rỗng nếu không có domain
    except Exception as e:
        # print(f"Không thể lấy domain name: {e}")
        return "diepxuan.corp"


@register_command
def d_host_domain():
    """In tên domain của máy."""
    print(_host_domain())


def _host_fullname():
    """Trả về tên hostname đầy đủ (FQDN) của máy."""
    try:
        # getfqdn() sẽ cố gắng phân giải để có tên đầy đủ nhất
        return socket.getfqdn()
    except Exception as e:
        # print(f"Không thể lấy FQDN: {e}")
        return _host_name() + "." + _host_domain()  # Trả về hostname ngắn nếu thất bại


@register_command
def d_host_fullname():
    """In tên hostname đầy đủ (FQDN) của máy."""
    print(_host_fullname())
