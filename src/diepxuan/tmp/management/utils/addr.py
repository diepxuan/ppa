#!/usr/bin/env python3

import subprocess
import socket
import ipaddress
import re
from urllib import request

from .registry import register_command
from . import _is_root
from . import host


def is_docker_ip(ip: str) -> bool:
    """Kiểm tra nhanh IP có phải Docker không."""
    if not ip or not isinstance(ip, str):
        return False

    # Docker IP patterns
    patterns = [
        r"^172\.(1[7-9]|2[0-9]|3[0-1])\..*",  # 172.17.0.0/12
        r"^192\.168\.(64|65)\..*",  # Docker Desktop
        # r"^10\.0\..*",  # Docker swarm
        r"^10\.255\..*",  # Docker swarm
        r"^127\.0\.0\.11$",  # Docker internal DNS
        r"^172\.1[0-6]\..*",  # Sometimes Docker uses these too
    ]

    # Kiểm tra regex patterns
    for pattern in patterns:
        if re.match(pattern, ip):
            return True

    # Kiểm tra bằng ipaddress module (chính xác hơn)
    try:
        ip_obj = ipaddress.ip_address(ip)

        # Check subnet ranges
        docker_subnets = [
            ipaddress.ip_network("172.17.0.0/16"),
            ipaddress.ip_network("172.18.0.0/16"),
            ipaddress.ip_network("172.19.0.0/16"),
            ipaddress.ip_network("172.20.0.0/14"),  # Covers 172.20-172.23
            ipaddress.ip_network("192.168.64.0/24"),
            ipaddress.ip_network("192.168.65.0/24"),
            # ipaddress.ip_network("10.0.0.0/24"),
            ipaddress.ip_network("10.255.0.0/16"),
        ]

        for subnet in docker_subnets:
            if ip_obj in subnet:
                return True

    except ValueError:
        pass

    return False


def can_reach_internet(ip: str) -> bool:
    """Kiểm tra IP có thể ra internet không."""
    test_services = [
        ("8.8.8.8", 53),  # Google DNS (UDP)
        ("1.1.1.1", 80),  # Cloudflare HTTP
        ("api.ipify.org", 80),  # Public IP service
    ]

    for host, port in test_services:
        try:
            # Bind socket đến IP cụ thể
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sock.settimeout(2)
            sock.bind((ip, 0))

            if port == 53:
                # DNS query test
                sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                sock.bind((ip, 0))
                sock.sendto(
                    b"\x00\x00\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x07example\x03com\x00\x00\x01\x00\x01",
                    (host, port),
                )
                sock.settimeout(1)
                sock.recvfrom(1024)
            else:
                # TCP connection test
                sock.connect((host, port))
                sock.send(b"GET / HTTP/1.0\r\n\r\n")

            sock.close()
            return True

        except (socket.timeout, socket.error, OSError):
            continue

    return False


def _ip_locals():
    """Lấy danh sách tất cả các địa chỉ IP non-loopback của máy."""
    ips = []

    # Phương pháp 1: Dùng netifaces (chính xác nhất)
    try:
        import netifaces

        for interface in netifaces.interfaces():
            try:
                addrs = netifaces.ifaddresses(interface)
                # Lấy địa chỉ IPv4
                if netifaces.AF_INET in addrs:
                    for addr_info in addrs[netifaces.AF_INET]:
                        ip = addr_info["addr"]
                        if ip != "127.0.0.1" and not ip.startswith("127."):
                            if ip not in ips:
                                ips.append(ip)
            except ValueError:
                continue
    except ImportError:
        # netifaces không có sẵn, dùng phương pháp khác
        pass

    if not ips:
        try:
            # Lấy tất cả các địa chỉ liên kết với hostname
            # getaddrinfo trả về các tuple phức tạp, ta chỉ cần IP
            addr_info = socket.getaddrinfo(
                host._host_name(),
                None,
                family=socket.AF_INET,  # Chỉ IPv4
                type=socket.SOCK_STREAM,
            )
            # print(host._host_name())
            # print(addr_info)
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

    # Chỉ giữ IP có thể kết nối internet
    ips = [ip for ip in ips if can_reach_internet(ip)]
    ips = [ip for ip in ips if not is_docker_ip(ip)]

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


@register_command
def d_ip_locals():
    """In toan bo địa chỉ IP nội bộ (Local IP)"""
    print(_ip_locals())


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
