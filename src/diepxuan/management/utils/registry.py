# Đây là nơi tập trung, được import bởi tất cả các module khác
import importlib
import logging
import os
import sys

COMMANDS = {}


def register_command(func):
    """Decorator để tự động đăng ký một hàm lệnh."""
    if callable(func) and func.__name__.startswith("d_"):
        # 1. Lấy tên hàm gốc (ví dụ: "d_vm_list")
        original_name = func.__name__

        # 2. Bỏ tiền tố "d_" (ví dụ: "vm_list")
        base_name = original_name[2:]

        # 3. Chuyển đổi tất cả dấu '_' thành ':' (ví dụ: "vm:list")
        command_name = base_name.replace("_", ":")

        # 4. Đăng ký lệnh với tên đã được chuyển đổi
        COMMANDS[command_name] = func
    return func
