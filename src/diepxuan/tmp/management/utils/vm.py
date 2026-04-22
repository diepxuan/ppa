#!/usr/bin/env python3

import sys
from . import system_os
from . import addr
from . import host
from . import Console
from . import Table
from . import system_metrics
from .registry import register_command
import logging
import requests
import psutil

TOKEN = "3ccbb8eb47507c42a3dfd2a70fe8e617509f8a9e4af713164e0088c715d24c83"
API_BASE = "https://dns.diepxuan.corp:53443/api"
API_BASE = "https://dns.diepxuan.io.vn/api"


def _vm_info():
    """Display VM Information"""
    console = Console()
    table = Table(
        # title="\n[bold yellow]Các lệnh có sẵn[/bold yellow]",
        show_header=False,  # <-- TẮT tiêu đề cột
        # box=None,  # <-- TẮT tất cả các đường viền
        padding=(
            0,
            2,
            0,
            0,
        ),  # <-- (top, right, bottom, left) - Chỉ thêm padding bên phải cột lệnh
    )
    table.add_row("Hostname", host._host_fullname())
    table.add_row("IP Address", addr._ip_local())
    table.add_row("DISTRIB", system_os._os_distro())
    table.add_row("OS", system_os._os_codename())
    table.add_row("RELEASE", system_os._os_release())
    table.add_row("ARCHITECTURE", system_os._os_architecture())
    table.add_row("")
    mem = system_metrics.memory_usage()
    memKB = mem / 1024
    memMB = mem / 1024
    table.add_row("memory_usage", f"{memKB:.2f} MB")

    # In bảng ra console
    console.print(table)


@register_command
def d_vm_info():
    """Display VM Information"""

    _vm_info()


def _vm_sync():
    """
    Đồng bộ các bản ghi DNS type 'A' cho hostname với các IP cục bộ hiện tại.
    """
    # 1. Thiết lập các biến
    headers = {
        "Cache-Control": "no-cache, no-store, must-revalidate",
        "Pragma": "no-cache",
        "Expires": "0",
    }

    params = {
        "token": TOKEN,
        "domain": host._host_fullname(),
        "zone": host._host_domain(),
    }
    url_get = f"{API_BASE}/zones/records/get"
    url_add = f"{API_BASE}/zones/records/add"
    url_del = f"{API_BASE}/zones/records/delete"

    with requests.Session() as requestsSession:
        requestsSession.headers.update(headers)

        try:
            res = requestsSession.get(
                url_get,
                params={**params, "listZone": "true"},
                timeout=10,
                verify=True,  # verify=False nếu dùng cert tự ký
            )
            res.raise_for_status()
            data = res.json()
        except Exception as e:
            logging.warning(f"DNS fetch failed: {e}")
            return

        old_ips = {
            rec["rData"]["ipAddress"]
            for rec in data.get("response", {}).get("records", [])
            if rec.get("type") == "A" and rec.get("name") == host._host_fullname()
        }

        new_ips = set(addr._ip_locals())
        if not new_ips:
            return

        for ip in old_ips - new_ips:
            try:
                requestsSession.get(
                    url_del,
                    params={**params, "type": "A", "ipAddress": ip},
                    headers=headers,
                    timeout=5,
                    verify=True,
                )
            except Exception:
                pass

        for ip in new_ips - old_ips:
            try:
                requestsSession.post(
                    url_add,
                    params={
                        **params,
                        "type": "A",
                        "ipAddress": ip,
                        "ptr": "true",
                        "createPtrZone": "true",
                    },
                    headers=headers,
                    timeout=5,
                    verify=True,
                )
            except Exception:
                pass


@register_command
def d_vm_sync():
    """
    Đồng bộ các bản ghi DNS type 'A' cho hostname với các IP cục bộ hiện tại.
    """
    _vm_sync()
