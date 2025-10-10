#!/usr/bin/env python3
import os
import sys
from . import register_command
from . import COMMANDS
from . import PACKAGE_NAME


def _commands():
    """Hiển thị danh sách commands"""
    return sorted(list(COMMANDS.keys()))


@register_command
def d_commands():
    """Hiển thị danh sách commands"""
    print(" ".join(_commands()))
