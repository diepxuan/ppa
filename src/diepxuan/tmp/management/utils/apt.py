#!/usr/bin/env python3
"""
APT package management utilities.

Chuyển đổi từ src/var/lib/apt.sh sang Python module.
"""

import subprocess
import sys
from . import register_command
from .system import _is_root


def _run_cmd(cmd, check=False):
    """Run shell command với sudo nếu cần."""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            check=check,
            capture_output=True,
            text=True,
        )
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except subprocess.CalledProcessError as e:
        return e.returncode, "", str(e)
    except Exception as e:
        return 1, "", str(e)


def _sudo_prefix(cmd):
    """Thêm sudo prefix nếu không phải root."""
    if _is_root():
        return cmd
    return f"sudo {cmd}"


@register_command
def d_apt_fix(args=None):
    """
    Apt fix lock files.
    
    Usage: ductn apt-fix
    """
    if args and "--help" in args:
        print("Apt fix lock files - Xóa lock files và fix dpkg")
        return
    
    print("Fixing APT lock files...")
    
    # Kill processes
    _run_cmd(_sudo_prefix("killall apt-get"))
    _run_cmd(_sudo_prefix("killall apt"))
    
    # Remove lock files
    lock_files = [
        "/var/lib/apt/lists/lock",
        "/var/cache/apt/archives/lock",
        "/var/lib/dpkg/lock",
        "/var/lib/dpkg/lock-frontend",
    ]
    
    for lock_file in lock_files:
        _run_cmd(_sudo_prefix(f"rm -f {lock_file}"))
    
    # Configure dpkg
    print("Configuring dpkg...")
    returncode, stdout, stderr = _run_cmd(_sudo_prefix("dpkg --configure -a"))
    
    if returncode == 0:
        print("APT lock files fixed successfully.")
    else:
        print(f"Error fixing APT: {stderr}", file=sys.stderr)
        sys.exit(1)


@register_command
def d_apt_check(args=None):
    """
    Apt check if package is installed.
    
    Usage: ductn apt-check <package-name>
    Returns: 1 if installed, 0 if not installed
    """
    if args and "--help" in args:
        print("Apt check if package is installed")
        print("Usage: ductn apt-check <package-name>")
        return
    
    if not args or len(args) == 0:
        print("Error: Package name required", file=sys.stderr)
        print("Usage: ductn apt-check <package-name>")
        sys.exit(1)
    
    package_name = args[0]
    
    # Check using dpkg -s
    returncode, stdout, stderr = _run_cmd(f"dpkg -s {package_name} 2>/dev/null | grep 'install ok installed'")
    
    if returncode != 0:
        print("0")  # Not installed
    else:
        print("1")  # Installed


@register_command
def d_apt_install(args=None):
    """
    Apt install package(s) if not already installed.
    
    Usage: ductn apt-install <package1> [package2 ...]
    """
    if args and "--help" in args:
        print("Apt install package(s) if not already installed")
        print("Usage: ductn apt-install <package1> [package2 ...]")
        return
    
    if not args or len(args) == 0:
        print("Error: Package name(s) required", file=sys.stderr)
        print("Usage: ductn apt-install <package1> [package2 ...]")
        sys.exit(1)
    
    for package in args:
        # Check if already installed
        returncode, stdout, stderr = _run_cmd(f"dpkg -s {package} 2>/dev/null | grep 'install ok installed'")
        
        if returncode != 0:
            # Not installed, install it
            print(f"Installing {package}...")
            cmd = _sudo_prefix(f"apt install {package} -y --purge --auto-remove")
            returncode, stdout, stderr = _run_cmd(cmd, check=False)
            
            if returncode == 0:
                print(f"Installed {package} successfully.")
            else:
                print(f"Error installing {package}: {stderr}", file=sys.stderr)
        else:
            print(f"Package {package} is already installed.")


@register_command
def d_apt_remove(args=None):
    """
    Apt remove package(s) with purge and auto-remove.
    
    Usage: ductn apt-remove <package1> [package2 ...]
    """
    if args and "--help" in args:
        print("Apt remove package(s) with purge and auto-remove")
        print("Usage: ductn apt-remove <package1> [package2 ...]")
        return
    
    if not args or len(args) == 0:
        print("Error: Package name(s) required", file=sys.stderr)
        print("Usage: ductn apt-remove <package1> [package2 ...]")
        sys.exit(1)
    
    packages = " ".join(args)
    print(f"Removing {packages}...")
    
    cmd = _sudo_prefix(f"apt remove {packages} -y --purge --auto-remove")
    returncode, stdout, stderr = _run_cmd(cmd, check=False)
    
    if returncode == 0:
        print(f"Removed {packages} successfully.")
    else:
        print(f"Error removing {packages}: {stderr}", file=sys.stderr)
        sys.exit(1)


@register_command
def d_apt_uninstall(args=None):
    """
    Apt uninstall package(s) (alias for apt-remove).
    
    Usage: ductn apt-uninstall <package1> [package2 ...]
    """
    if args and "--help" in args:
        print("Apt uninstall package(s) (alias for apt-remove)")
        print("Usage: ductn apt-uninstall <package1> [package2 ...]")
        return
    
    # Gọi lại d_apt_remove
    d_apt_remove(args)
