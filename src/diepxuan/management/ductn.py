#!/usr/bin/env python3

import argparse
import sys
import os
import platform
import subprocess
import importlib.util

from utils import *


def main():

    parser = argparse.ArgumentParser(
        prog="ductn",
        # description="DiepXuan Corp",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Tự động sinh subcommand từ COMMANDS
    for cmd_name, func in COMMANDS.items():
        doc = func.__doc__
        description = doc.strip().split("\n")[0] if doc else ""
        sub = subparsers.add_parser(cmd_name, help=description or "No description")
        # if "start" in cmd_name or "stop" in cmd_name:
        #     sub.add_argument("name", help="Tên VM")
        sub.set_defaults(func=func)

    # Kích hoạt autocomplete nếu chạy CLI trực tiếp
    if sys.argv[0].endswith(("ductn", "ductn.py", "ductn.sh")):
        try:
            import argcomplete
        except ImportError:
            argcomplete = None
        argcomplete.autocomplete(parser)

    args = parser.parse_args()
    func = args.func

    if func:
        import inspect

        sig = inspect.signature(func)
        if len(sig.parameters) == 0:
            func()
        else:
            func(args)


if __name__ == "__main__":
    main()
