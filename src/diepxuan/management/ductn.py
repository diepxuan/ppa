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

            argcomplete.autocomplete(parser)
        except:
            pass  # nếu không có argcomplete vẫn chạy bình thường

    args = parser.parse_args()
    command.command_run(args.func, args)


if __name__ == "__main__":
    main()
