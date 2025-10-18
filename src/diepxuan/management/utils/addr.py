#!/usr/bin/env python3

import subprocess
import socket
from urllib import request

from .registry import register_command
from . import _is_root
from . import host


def _ip_locals():
    """Lấy danh sách tất cả các địa chỉ IP non-loopback của máy."""
    ips = []
    try:
        # Lấy tất cả các địa chỉ liên kết với hostname
        # getaddrinfo trả về các tuple phức tạp, ta chỉ cần IP
        addr_info = socket.getaddrinfo(host._host_name(), None)
        for item in addr_info:
            ip = item[4][0]
            if ip not in ips and not ip.startswith("127."):
                ips.append(ip)
    except socket.gaierror:
        # Nếu không phân giải được hostname, thử cách khác
        pass
    # Dự phòng nếu cách trên thất bại (ví dụ hostname không đúng)
    if not ips:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
                s.connect(("8.8.8.8", 80))
                ips.append(s.getsockname()[0])
        except Exception:
            pass  # Bỏ qua nếu không có mạng

    return ips if ips else []


def _ip_local(interface: str = None) -> str:
    """
    Lấy địa chỉ IP của một interface cụ thể, hoặc IP chính của máy.
    """
    if _is_root() is False:
        return ""
    if not interface:
        s = None
        try:
            # Tạo một socket UDP. AF_INET là cho IPv4, SOCK_DGRAM là cho UDP.
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

            # Không cần gửi dữ liệu, chỉ cần "kết nối" để hệ điều hành chọn interface.
            # Địa chỉ IP không cần phải tồn tại hoặc đến được.
            s.connect(("8.8.8.8", 80))

            # getsockname() trả về một tuple (ip, port)
            ip_address = s.getsockname()[0]
            return ip_address
        except Exception:
            # Nếu có lỗi (ví dụ: không có kết nối mạng), trả về IP loopback
            # return "127.0.0.1"
            pass
        finally:
            # Luôn luôn đóng socket sau khi dùng xong
            if s:
                s.close()
    else:
        try:
            # Lệnh `ip addr show <interface>` và lọc bằng awk
            command = f"ip addr show {interface} | grep 'inet ' | awk '{{print $2}}' | cut -d/ -f1"
            result = subprocess.run(
                command, shell=True, capture_output=True, text=True, check=True
            )
            return result.stdout.strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            # logging.warning(f"Không thể lấy IP cho interface '{interface}'.")
            # return ""
            pass


@register_command
def d_ip_local():
    """In địa chỉ IP nội bộ (Local IP)"""
    print(_ip_local())


def _ip_wan():
    """
    Lấy địa chỉ IP WAN (Public IP) bằng cách gọi một dịch vụ API bên ngoài.
    Trả về None nếu không lấy được IP.
    """
    api_services = [
        "https://api.ipify.org",
        "https://ipinfo.io/ip",
        "https://checkip.amazonaws.com",
        "https://icanhazip.com",
    ]

    for url in api_services:
        # try:
        #     # Gửi một request GET đến API, đặt timeout để tránh chờ quá lâu
        #     response = requests.get(url, timeout=5)
        #     # Gây ra lỗi nếu request không thành công (vd: lỗi 4xx, 5xx)
        #     response.raise_for_status()

        #     # .text.strip() để lấy nội dung và xóa các khoảng trắng/dòng mới thừa
        #     return response.text.strip()
        # except requests.exceptions.RequestException as e:
        #     # Nếu có lỗi (timeout, không kết nối được...), thử dịch vụ tiếp theo
        #     # print(f"Lỗi khi truy cập {url}: {e}. Đang thử dịch vụ khác...")
        #     continue

        try:
            # ipify trả về text thuần, dễ xử lý nhất
            with request.urlopen(url, timeout=5) as response:
                return response.read().decode("utf-8").strip()
        except Exception as e:
            # print(f"Không thể lấy IP WAN: {e}")
            # return None
            continue

    # Nếu tất cả các dịch vụ đều thất bại
    return "0.0.0.0"


@register_command
def d_ip_wan():
    """In địa chỉ IP WAN (Public IP)"""
    print(_ip_wan())
