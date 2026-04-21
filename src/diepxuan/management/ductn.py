#!/usr/bin/env python3

import argparse
import inspect
import sys
import os
import platform
import subprocess
import importlib.util

from utils import *


def main():
    try:
        import argcomplete
        from argcomplete.completers import FilesCompleter
    except:
        argcomplete = None
        pass  # nếu không có argcomplete vẫn chạy bình thường

    parser = argparse.ArgumentParser(
        prog="ductn",
        description="DiepXuan Corp",
    )

    parser.add_argument(
        "-v", "--version", action="store_true", help="Show version and exit"
    )

    subparsers = parser.add_subparsers(dest="command")
    # parser.add_argument(
    #     "extra_args", nargs=argparse.REMAINDER, help="Extra arguments for the command"
    # )

    # Tự động sinh subcommand từ COMMANDS
    for cmd_name, func in COMMANDS.items():
        description = func.__doc__.strip().split("\n")[0] if func.__doc__ else ""
        sub = subparsers.add_parser(cmd_name, help=description or "No description")
        # if "start" in cmd_name or "stop" in cmd_name:
        #     sub.add_argument("name", help="Tên VM")
        sub.set_defaults(func=func)

        # Nếu hàm có tham số -> cho phép nhận args động
        sig = inspect.signature(func)
        if len(sig.parameters) > 0:
            # sub.add_argument(
            #     "extra_args",
            #     nargs=argparse.REMAINDER,
            #     help="Extra arguments for this command",
            # )
            if argcomplete:
                sub.add_argument(
                    "extra_args",
                    nargs=argparse.REMAINDER,
                    help="Extra arguments for this command",
                ).completer = FilesCompleter()
            else:
                sub.add_argument(
                    "extra_args",
                    nargs=argparse.REMAINDER,
                    help="Extra arguments for this command",
                )

    # Kích hoạt autocomplete nếu chạy CLI trực tiếp
    # if sys.argv[0].endswith(("ductn", "ductn.py", "ductn.sh")) and argcomplete:
    #     argcomplete.autocomplete(parser)
    if argcomplete:
        argcomplete.autocomplete(parser)

    # Nếu không có subcommand → hiển thị help
    args, unknown = parser.parse_known_args()

    if args.version:
        print(about._version())
        sys.exit(0)

    if not args.command:
        parser.print_help()
        sys.exit(1)

    func = getattr(args, "func", None)
    if not func:
        parser.print_help()
        return

    # args = parser.parse_args()
    # print(args)
    # if not args.command:
    #     parser.print_help()
    #     return

    # func = getattr(args, "func", None)
    # if not func:
    #     parser.print_help()
    #     return

    # # Chuẩn hóa extra_args
    extra_args = getattr(args, "extra_args", [])
    command.command_run(func, extra_args)

    # args = parser.parse_args()
    # print(args)
    # command.command_run(args.func, args)


if __name__ == "__main__":
    main()
