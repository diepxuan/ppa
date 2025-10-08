#!/usr/bin/env python3

import sys
import os
import platform
import subprocess
import importlib.util

from utils import *

# from utils.registry import COMMANDS

# 1. Biến toàn cục và xác định đường dẫn
GLOBAL_EXEC_PREFIX = "d_"
PACKAGE_NAME = "ductn"
SERVICE_NAME = "ductnd"
SRC_DIR = os.path.dirname(os.path.realpath(__file__))


def main():
    args = sys.argv[1:]

    if not args:
        COMMANDS["help"]()
        sys.exit(0)

    command_name = args[0]
    command_args = args[1:]

    if command_name in COMMANDS:
        command_function = COMMANDS[command_name]

        try:
            # Thực thi hàm với các tham số còn lại
            # Dấu * sẽ "giải nén" (unpack) list `command_args`
            # thành các tham số riêng lẻ cho hàm.
            # Ví dụ: nếu command_args là ['vm1'], nó sẽ gọi command_function('vm1')
            command_function(*command_args)

            # Thoát với mã thành công
            sys.exit(0)

        except TypeError as e:
            # Bắt lỗi nếu số lượng tham số không khớp
            print(f"Lỗi: Sai số lượng tham số cho lệnh '{command_name}'.")
            # In ra thông tin hàm để người dùng biết cách dùng (nâng cao)
            import inspect

            print(
                f"Cách dùng: {command_name} {' '.join(inspect.signature(command_function).parameters)}"
            )
            sys.exit(1)

        except Exception as e:
            # Bắt các lỗi khác có thể xảy ra trong quá trình thực thi
            print(f"Lỗi khi thực thi lệnh '{command_name}': {e}", file=sys.stderr)
            sys.exit(1)

    else:
        # --- Trường hợp 4: Lệnh không tồn tại ---
        # Nếu không tìm thấy lệnh, báo lỗi và hiển thị help
        print(f"Lỗi: Lệnh '{command_name}' không hợp lệ.")
        COMMANDS["help"]()  # Gọi hàm help
        sys.exit(0)  # Thoát với mã lỗi 0


if __name__ == "__main__":
    main()
