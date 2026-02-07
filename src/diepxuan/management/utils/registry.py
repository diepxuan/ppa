# Đây là nơi tập trung, được import bởi tất cả các module khác
import importlib
import logging
import os
import sys
from .init_action import _get_init_system

COMMANDS = {}
INIT_ACTIONS = {}


def register_command(*aliases):
    """Decorator để tự động đăng ký một hàm lệnh và alias."""
    # Nếu dùng trực tiếp @register_command
    if len(aliases) == 1 and callable(aliases[0]):
        func = aliases[0]
        aliases = []
        return _register_command(func, aliases)

    # Nếu dùng @register_command("alias1", "alias2")
    def wrapper(func):
        return _register_command(func, aliases)

    return wrapper


def _register_command(func, aliases):
    """Decorator hàm nội bộ tự động đăng ký một hàm lệnh."""
    if callable(func) and func.__name__.startswith("d_"):
        # 1. Lấy tên hàm gốc (ví dụ: "d_vm_list")
        original_name = func.__name__

        # 2. Bỏ tiền tố "d_" (ví dụ: "vm_list")
        base_name = original_name[2:]

        # 3. Chuyển đổi tất cả dấu '_' thành ':' (ví dụ: "vm:list")
        command_name = base_name.replace("_", ":")

        # 4. Đăng ký lệnh với tên đã được chuyển đổi
        COMMANDS[command_name] = func

        # Đăng ký alias
        for alias in aliases:
            COMMANDS[alias] = func

    return func


def register_init_action(*actions):
    """
    Decorator để đăng ký action theo init system.
    Tên action được suy ra từ tên hàm: _{init}_{action}
    """

    # Nếu dùng trực tiếp @register_command
    if len(actions) == 1 and callable(actions[0]):
        func = actions[0]
        actions = []
        return _register_init_action(func, actions)

    # Nếu dùng @register_command("alias1", "alias2")
    def wrapper(func):
        return _register_init_action(func, actions)

    return wrapper


def _register_init_action(func, actions):
    """Decorator hàm nội bộ tự động đăng ký action theo init."""
    fname = func.__name__
    if callable(func) and fname.startswith("_"):
        # Chỉ xử lý các hàm dạng _init_action
        if not fname.startswith("_"):
            return func

        # _launchd_host_name → ['launchd', 'host_name']
        parts = fname[1:].split("_", 1)
        if len(parts) != 2:
            return func

        func_init, action = parts
        current_init = _get_init_system()

        # Nếu init không khớp → bỏ qua
        if func_init != current_init:
            return func

        key = f"{func_init}_{action}"
        INIT_ACTIONS[key] = func

        return func

    return func


def call_init_action(action, init=None):
    """
    Gọi action theo init system.
    Nếu init=None → tự detect bằng _get_init_system()
    """
    if init is None:
        init = _get_init_system()
    fn_name = f"_{init}_{action}"
    fn = globals().get(fn_name)

    key = f"{init}_{action}"
    fn = INIT_ACTIONS.get(key)

    if not fn:
        raise RuntimeError(f"Unsupported init/action: {fn_name}")

    return fn()
