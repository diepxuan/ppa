import os
import re
import subprocess
import ductn
from ductn import SRC_DIR
from .registry import COMMANDS, register_command

from . import Console
from . import Table


@register_command
def d_help():
    """Show help information"""
    console = Console()
    console.print(f"\n[bold cyan]Cách sử dụng:[/bold cyan] ductn <lệnh> [tham số]\n")
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
    for command_name in sorted(COMMANDS.keys()):
        command_func = COMMANDS[command_name]

        doc = command_func.__doc__
        # description = doc.strip().split("\n")[0] if doc else "Không có mô tả."
        description = doc.strip().split("\n")[0] if doc else ""

        table.add_row(f"[green]{command_name}[/green]", description)

    # In bảng ra console
    console.print(table)


def _version():

    try:
        # Chạy lệnh `apt show <package_name>`
        # `capture_output=True` để lấy stdout, `text=True` để output là string
        # `check=True` sẽ gây ra exception nếu lệnh thất bại
        result = subprocess.run(
            ["apt", "show", ductn.__name__],
            capture_output=True,
            text=True,
            check=False,
            stderr=subprocess.DEVNULL,
        )

        if result.returncode == 0:
            # Dùng regex để tìm dòng "Version: ..." và trích xuất phiên bản
            match = re.search(r"^Version:\s*([^\s]+)", result.stdout, re.MULTILINE)
            if match:
                version = match.group(1)
                # Đôi khi apt show trả về thông tin epoch (vd: 2:1.2.3-4)
                # Đoạn này sẽ loại bỏ nó nếu có. Tùy chọn.
                if ":" in version:
                    version = version.split(":", 1)[1]
                return version
    except FileNotFoundError:
        # Xử lý trường hợp không tìm thấy lệnh `apt`
        pass
    except Exception:
        # Bắt các lỗi khác có thể xảy ra
        pass

    changelog_path = os.path.join(SRC_DIR, "debian", "changelog")

    if os.path.exists(changelog_path):
        try:
            with open(changelog_path, "r", encoding="utf-8") as f:
                first_line = f.readline()
                # Regex tìm chuỗi nằm giữa cặp dấu ngoặc đơn đầu tiên
                match = re.search(r"\((.*?)\)", first_line)
                if match:
                    version = match.group(1).strip()
                    if version:
                        return version
        except Exception:
            # Lỗi đọc file, không sao, chuyển sang cách tiếp theo
            pass

        try:
            with open(changelog_path, "r", encoding="utf-8") as f:
                first_line = f.readline()
                # Regex tìm chuỗi nằm giữa cặp dấu ngoặc đơn đầu tiên
                match = re.search(r"\((.*?)\)", first_line)
                if match:
                    version = match.group(1).strip()
                    if version:
                        return version
        except Exception:
            # Lỗi đọc file, chuyển sang cách cuối cùng
            pass

        try:
            # `find_executable` kiểm tra xem lệnh có tồn tại không
            from shutil import which

            if which("dpkg-parsechangelog"):
                result = subprocess.run(
                    ["dpkg-parsechangelog", "-S", "Version", "-l", changelog_path],
                    # capture_output=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.DEVNULL,
                    text=True,
                    check=True,
                )
                version = result.stdout.strip()
                if version:
                    return version
        except (ImportError, FileNotFoundError, subprocess.CalledProcessError):
            # Lệnh không tồn tại hoặc chạy thất bại, chuyển sang cách tiếp theo
            pass

    return "0.0.0"


@register_command
def d_version():
    """Show package version"""

    print(_version())


@register_command
def d_version_newrelease():
    """Get next release version"""
    version = _version()
    # Loại bỏ phần sau dấu + nếu có
    version = version.split("+", 1)[0]
    # Loại bỏ dấu chấm để dễ dàng tăng số
    numeric_version = version.replace(".", "")
    if numeric_version.isdigit():
        next_version_num = int(numeric_version) + 1
        # Đảm bảo định dạng x.y.z
        next_version_str = str(next_version_num).zfill(3)
        next_version = (
            f"{next_version_str[0]}.{next_version_str[1]}.{next_version_str[2]}"
        )
        print(next_version)
    else:
        print("0.0.0")
