import logging
import os
import platform
import subprocess
import sys

from ductn import PACKAGE_NAME

from .registry import register_command
from . import distro


def _sys_update():
    """
    Kiểm tra phiên bản mới của một package .deb qua apt và đề nghị cập nhật.
    Yêu cầu quyền sudo để chạy các lệnh apt update/install.
    """
    # global PACKAGE_NAME
    # if os.geteuid() != 0:
    #     logging.error(
    #         "Lỗi: Chức năng này yêu cầu quyền root (sudo) để chạy.", file=sys.stderr
    #     )
    #     return

    # logging.info("đã chạy với sudo")

    # logging.info("-> Đang làm mới danh sách gói (apt update)...")
    try:
        subprocess.run(["apt", "update"], check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        logging.error("Lỗi: Không thể chạy 'apt update'.")
        logging.error(f"Stderr: {e.stderr}")
        return
    except FileNotFoundError:
        logging.error(
            "Lỗi: Không tìm thấy lệnh 'apt'. Script này chỉ dành cho hệ thống Debian/Ubuntu."
        )
        return

    # logging.info(f"-> Đang kiểm tra phiên bản cho '{PACKAGE_NAME}'...")
    installed_version = None
    candidate_version = None
    try:
        # Chạy `apt-cache policy`
        result = subprocess.run(
            ["apt-cache", "policy", PACKAGE_NAME],
            capture_output=True,
            text=True,
            check=True,
        )
        # Phân tích output
        for line in result.stdout.splitlines():
            line = line.strip()
            if line.startswith("Installed:"):
                installed_version = line.split(":", 1)[1].strip()
            elif line.startswith("Candidate:"):
                candidate_version = line.split(":", 1)[1].strip()

    except subprocess.CalledProcessError:
        logging.error(
            f"Lỗi: Không tìm thấy package '{PACKAGE_NAME}' trong kho lưu trữ."
        )
        return

    # Kiểm tra xem đã lấy được thông tin chưa
    if not installed_version or installed_version == "(none)":
        logging.info(f"Thông tin: Package '{PACKAGE_NAME}' chưa được cài đặt.")
        return
    if not candidate_version:
        logging.error(
            f"Lỗi: Không thể xác định phiên bản mới nhất cho '{PACKAGE_NAME}'."
        )
        return

    # logging.info(f"   - Phiên bản đã cài: {installed_version}")
    # logging.info(f"   - Phiên bản mới nhất:  {candidate_version}")

    # --- 4. So sánh phiên bản ---
    # Sử dụng `dpkg --compare-versions` để so sánh một cách đáng tin cậy
    # `dpkg --compare-versions 1.0 gt 0.9` -> exit code 0 (true)
    # `dpkg --compare-versions 1.0 gt 1.1` -> exit code 1 (false)
    # `gt` là "greater than"
    has_new_version = (
        subprocess.run(
            ["dpkg", "--compare-versions", candidate_version, "gt", installed_version],
            capture_output=True,
        ).returncode
        == 0
    )

    if has_new_version:
        try:
            # Sử dụng `apt install` thay vì `apt upgrade` để chỉ nâng cấp một gói duy nhất
            # `--only-upgrade` đảm bảo nó không cài mới nếu gói chưa tồn tại
            result = subprocess.run(
                ["apt", "install", "--only-upgrade", "-y", PACKAGE_NAME],
                check=True,
                capture_output=True,
                text=True,
            )
            # logging.info("Cập nhật thành công!")
            # In ra vài dòng cuối của output để xem tóm tắt
            # logging.info("\n".join(result.stdout.strip().splitlines()[-5:]))
            # logging.info("\nVui lòng khởi động lại ứng dụng nếu cần.")

        except subprocess.CalledProcessError as e:
            logging.error("\n--- LỖI KHI CẬP NHẬT ---")
            logging.error("Lệnh 'apt install' đã thất bại.")
            logging.error(f"Stderr:\n{e.stderr}")
            logging.error("--------------------------")


@register_command
def d_sys_update():
    """
    Kiểm tra phiên bản mới.
    """
    _sys_update()


@register_command
def d_update():
    """
    Kiểm tra phiên bản mới (sys:update alias).
    """
    d_sys_update()
