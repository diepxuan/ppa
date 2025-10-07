import logging
import re
import subprocess
import time

from utils.registry import register_command


PING_HOST = "8.8.8.8"
# CHECK_INTERVAL_SECONDS = 30


def _route_default() -> str:
    """
    Tự động tìm tên của interface mạng chính, ngay cả khi không có default route.
    Ưu tiên 1: Tìm default route hiện có.
    Ưu tiên 2: Tìm interface có gateway được cấu hình trong `ip route show table all`.
    Ưu tiên 3: Lấy interface đầu tiên không phải 'lo' có trạng thái UP và có IP.
    """

    # --- Ưu tiên 1: Tìm default route đang hoạt động ---
    try:
        cmd = ["ip", "route", "show", "default"]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        output = result.stdout.strip()
        # Mẫu output: default via 192.168.1.1 dev eth0
        match = re.search(r"dev\s+([^\s]+)", output)
        if match:
            interface = match.group(1)
            # logging.info(
            #     f"Tìm thấy default route đang hoạt động qua interface: '{interface}'"
            # )
            return interface
    except (subprocess.CalledProcessError, FileNotFoundError):
        # Không có default route, chuyển sang cách tiếp theo
        pass

    # --- Ưu tiên 2: Tìm trong tất cả các bảng định tuyến (bao gồm cả cấu hình đã lưu) ---
    try:
        cmd = ["ip", "route", "show", "table", "all"]
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
        )
        # Tìm dòng 'default' đầu tiên, vì nó thường là cấu hình chính
        for line in result.stdout.strip().splitlines():
            if line.startswith("default"):
                match = re.search(r"dev\s+([^\s]+)", line)
                if match:
                    interface = match.group(1)
                    # logging.info(
                    #     f"Tìm thấy cấu hình default route (có thể không hoạt động) qua interface: '{interface}'"
                    # )
                    return interface
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    # --- Ưu tiên 3: Tìm interface "có vẻ" là chính nhất ---
    try:
        cmd = ["ip", "addr", "show"]  # Chỉ lấy IPv4
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
        )

        # Phân tích output của `ip addr`
        interfaces = {}
        current_if = None
        for line in result.stdout.strip().splitlines():
            # Dòng bắt đầu một interface mới
            if line[0].isdigit():
                match = re.search(r"^\d+:\s+([^\s:]+):", line)
                if match:
                    current_if = match.group(1).split("@")[0]
                    if current_if != "lo":
                        interfaces[current_if] = {"state": "DOWN", "ip": None}
                        if "UP" in line:
                            interfaces[current_if]["state"] = "UP"
            # # Dòng chứa địa chỉ inet
            elif "inet " in line and current_if and current_if != "lo":
                ip_match = re.search(r"inet\s+([\d\.]+)", line)
                if ip_match:
                    interfaces[current_if]["ip"] = ip_match.group(1)
        # print(interfaces)

        # Chọn interface đầu tiên có trạng thái UP và có IP
        for if_name, data in interfaces.items():
            if data["state"] == "UP" and data["ip"]:
                # logging.info(
                #     f"Không tìm thấy default route, chọn interface đầu tiên đang UP và có IP: '{if_name}'"
                # )
                return if_name
    except Exception as e:
        # logging.error(f"Lỗi nghiêm trọng khi cố gắng phân tích các interface mạng: {e}")
        pass

    return ""


@register_command
def d_route_default():
    """
    Hiển thị default route hiện tại.
    """
    print(_route_default())


def _is_interface_up(interface: str) -> bool:
    """Kiểm tra xem interface có đang ở trạng thái UP hay không."""
    result = subprocess.run(
        ["ip", "addr", "show", interface],
        capture_output=True,
        text=True,
        check=True,
    )
    if result.returncode != 0:
        # logging.error(f"Không tìm thấy interface '{interface}'.")
        return False
    # Trạng thái UP được hiển thị trong output, ví dụ: <BROADCAST,MULTICAST,UP,LOWER_UP>
    return "state UP" in result.stdout


def _has_internet_connection(host: str) -> bool:
    """Kiểm tra kết nối Internet bằng cách ping đến một host."""
    # -c 1: Chỉ gửi 1 gói tin
    # -W 5: Chờ tối đa 5 giây
    result = subprocess.run(
        ["ping", "-c", "1", "-W", "2", host],
        capture_output=True,
        text=True,
        check=True,
    )
    # returncode == 0 nghĩa là ping thành công
    return result.returncode == 0


def _interface_down(interface: str):
    """Down interface."""
    # logging.warning(f"Không có kết nối Internet. Đang khởi động lại interface '{interface}'...")
    result = subprocess.run(
        ["ip", "link", "set", interface, "down"],
        capture_output=True,
        text=True,
        check=True,
    )


def _interface_up(interface: str):
    """Up interface."""
    # logging.warning(f"Không có kết nối Internet. Đang khởi động lại interface '{interface}'...")
    result = subprocess.run(
        ["ip", "link", "set", interface, "up"],
        capture_output=True,
        text=True,
        check=True,
    )


def _interface_reload(interface: str):
    """Khởi động lại (down rồi up) một interface mạng."""
    # logging.warning(f"Không có kết nối Internet. Đang khởi động lại interface '{interface}'...")
    _interface_down(interface)
    _interface_up(interface)


@register_command
def d_route_monitor():
    """
    Giám sát kết nối Internet và tự động khởi động lại interface mạng chính nếu mất kết nối.
    """
    _route_monitor()


def _route_monitor():
    """
    Giám sát kết nối Internet và tự động khởi động lại interface mạng chính nếu mất kết nối.
    """

    interface = _route_default()
    if not interface:
        # logging.error("Không xác định được interface mạng chính để giám sát.")
        return

    # logging.info(f"Giám sát kết nối Internet qua interface '{interface}'...")
    # while True:
    try:
        if not _is_interface_up(interface):
            _interface_up(interface)

        if _has_internet_connection(PING_HOST):
            # logging.info("Kết nối Internet ổn định.")
            pass
        else:
            # logging.warning("Không có kết nối Internet.")
            _interface_reload(interface)
            # time.sleep(5)  # Đợi 5 giây sau khi khởi động lại
            # if _has_internet_connection(PING_HOST):
            #     logging.info(
            #         "Đã khôi phục kết nối Internet sau khi khởi động lại interface."
            #     )
            # else:
            #     logging.error(
            #         "Vẫn không có kết nối Internet sau khi khởi động lại interface."
            #     )

        # time.sleep(CHECK_INTERVAL_SECONDS)
    except KeyboardInterrupt:
        # logging.info("Đã dừng giám sát kết nối Internet.")
        # break
        return
    except Exception as e:
        # logging.error(f"Lỗi nghiêm trọng trong quá trình giám sát: {e}")
        # time.sleep(CHECK_INTERVAL_SECONDS)
        return
