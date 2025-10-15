from shutil import which
import subprocess
import sys

from . import register_command


@register_command
def d_alias_ll(args):
    """
    Alias script ll. Displays directory contents in long format (like ls -la).
    """
    try:
        # subprocess.run sẽ thực thi lệnh và chờ nó hoàn thành.
        # Chúng ta không cần `capture_output` vì muốn in trực tiếp ra terminal.
        subprocess.run(["ls", "-lah"] + args, check=True)
    except FileNotFoundError:
        # Xảy ra nếu `ls` cũng không tồn tại (rất hiếm)
        # print(f"Lỗi: Không tìm thấy lệnh '{command_to_use[0]}'.", file=sys.stderr)
        pass
    except subprocess.CalledProcessError as e:
        # Xảy ra nếu lệnh chạy nhưng trả về mã lỗi (ví dụ: `ls` một thư mục không tồn tại)
        # Lỗi đã được in ra stderr bởi chính tiến trình con, nên không cần in lại.
        # Chỉ cần thoát với mã lỗi tương ứng.
        sys.exit(e.returncode)
    except Exception as e:
        print(f"Một lỗi không mong muốn đã xảy ra: {e}", file=sys.stderr)
