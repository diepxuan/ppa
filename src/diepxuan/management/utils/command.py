#!/usr/bin/env python3
import os
import sys
from . import register_command
from . import COMMANDS
from . import PACKAGE_NAME
from . import registry


def _commands():
    """Hiển thị danh sách commands"""
    return sorted(list(COMMANDS.keys()))


@register_command
def d_commands():
    """Hiển thị danh sách commands"""
    print(" ".join(_commands()))


# -------------------------------
# Chạy lệnh với args nếu cần
# -------------------------------
def command_run(func, args=None):
    import inspect

    sig = inspect.signature(func)
    if len(sig.parameters) == 0:
        func()
    else:
        func(args)
