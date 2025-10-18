#!/usr/bin/env python3

import sys
from . import system_info
from . import addr
from . import host
from . import Console
from . import Table
from .registry import register_command
import requests


@register_command
def d_vm_info():
    """Display VM Information"""

    print("VM Information:")
    console = Console()
    table = Table(
        # title="\n[bold yellow]Các lệnh có sẵn[/bold yellow]",
        show_header=False,  # <-- TẮT tiêu đề cột
        box=None,  # <-- TẮT tất cả các đường viền
        padding=(
            0,
            2,
            0,
            0,
        ),  # <-- (top, right, bottom, left) - Chỉ thêm padding bên phải cột lệnh
    )
    table.add_row("Hostname", host._host_fullname())
    table.add_row("IP Address", addr._ip_local())
    table.add_row("DISTRIB", system_info._os_distro())
    table.add_row("OS", system_info._os_codename())
    table.add_row("RELEASE", system_info._os_release())
    table.add_row("ARCHITECTURE", system_info._os_architecture())

    # In bảng ra console
    console.print(table)


def _vm_sync():
    """
    Đồng bộ các bản ghi DNS type 'A' cho hostname với các IP cục bộ hiện tại.
    """
    # 1. Thiết lập các biến
    TOKEN = "3ccbb8eb47507c42a3dfd2a70fe8e617509f8a9e4af713164e0088c715d24c83"
    API_BASE = "https://dns.diepxuan.corp:53443/api"
    API_BASE = "https://dns.diepxuan.io.vn/api"

    params = {
        "token": TOKEN,
        "domain": host._host_fullname(),
        # "domain": host._host_name(),
        "zone": host._host_domain(),
    }
    url_get = f"{API_BASE}/zones/records/get"
    url_add = f"{API_BASE}/zones/records/add"
    url_del = f"{API_BASE}/zones/records/delete"

    old_ips = set()
    try:
        # get_params = params | {"listZone": "true"}
        get_params = params.copy()
        get_params.update({"listZone": "true"})
        response = requests.get(
            url_get, params=get_params, timeout=10, verify=True
        )  # verify=False nếu dùng cert tự ký

        # print(f"Yêu cầu GET: {response.url}")  # In URL yêu cầu để kiểm tra
        response.raise_for_status()  # Gây ra lỗi nếu HTTP status không phải 2xx

        data = response.json()
        # print(f"Dữ liệu nhận được: {data}")  # In dữ liệu thô để kiểm tra
        if data.get("status") == "ok":
            records = data.get("response", {}).get("records", [])
            # Lọc và lấy ra các IP của bản ghi loại 'A'
            for record in records:
                if (
                    record.get("type") == "A"
                    and record.get("name") == host._host_fullname()
                ):
                    old_ips.add(record.get("rData", {}).get("ipAddress"))
            # print(f"Đã tìm thấy các IP cũ: {list(old_ips) or 'Không có'}")
    except requests.exceptions.RequestException as e:
        # print(f"Lỗi: Không thể lấy danh sách DNS cũ. {e}", file=sys.stderr)
        return  # Thoát nếu không lấy được dữ liệu ban đầu

    # print(old_ips)

    new_ips = set(addr._ip_locals())
    # print(new_ips)
    if not new_ips:
        # print("Lỗi: Không tìm thấy IP cục bộ nào trên máy.", file=sys.stderr)
        return
    # print(f"Các IP cục bộ hiện tại: {list(new_ips)}")

    ips_to_remove = old_ips - new_ips
    if ips_to_remove:
        # print(f"\nCác IP cần xóa: {list(ips_to_remove)}")
        for ip in ips_to_remove:
            del_params = params | {
                "type": "A",
                "ipAddress": ip,
            }
            try:
                res = requests.delete(
                    url_del, params=del_params, timeout=5, verify=True
                )
                res.raise_for_status()
                # print(f"  - Đã xóa thành công IP: {ip}")
            except requests.exceptions.RequestException as e:
                # print(f"  - Lỗi khi xóa IP {ip}: {e}", file=sys.stderr)
                pass

    ips_to_add = new_ips - old_ips
    if ips_to_add:
        # print(f"\nCác IP cần thêm: {list(ips_to_add)}")
        for ip in ips_to_add:
            add_params = params | {
                "type": "A",
                "ipAddress": ip,
            }
            try:
                res = requests.post(url_add, params=add_params, timeout=5, verify=True)
                res.raise_for_status()
                # print(f"  - Đã thêm thành công IP: {ip}")
            except requests.exceptions.RequestException as e:
                # print(f"  - Lỗi khi thêm IP {ip}: {e}", file=sys.stderr)
                pass


@register_command
def d_vm_sync():
    """
    Đồng bộ các bản ghi DNS type 'A' cho hostname với các IP cục bộ hiện tại.
    """
    _vm_sync()
