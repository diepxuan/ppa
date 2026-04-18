#!/usr/bin/env python3
"""
DNS management utilities.

Cross-platform support for macOS and Linux.
"""

import os
import platform
import subprocess
import logging
from typing import List, Optional

from . import register_command
from .system import _is_root
from .interface import get_active_service


# Constants
SYSTEM = platform.system()  # "Linux" or "Darwin"
DNS_SERVER = "10.0.0.103"
TEST_DOMAIN = "google.com"
STATIC_DNS_SERVERS = ["1.1.1.1", "8.8.8.8"]
SEARCH_DOMAIN = "diepxuan.corp"


def _run_cmd(cmd: List[str], check: bool = False) -> int:
    """Run command and return returncode."""
    try:
        result = subprocess.run(
            cmd,
            check=check,
            capture_output=True,
            text=True,
        )
        return result.returncode
    except subprocess.CalledProcessError as e:
        return e.returncode
    except Exception as e:
        logging.error(f"Command failed: {e}")
        return 1


def _ping_ok(dns_server: str = DNS_SERVER) -> bool:
    """Check if DNS server is reachable via ping."""
    returncode = _run_cmd(["ping", "-c", "1", "-W", "1000", dns_server])
    return returncode == 0


def _dns_ok(dns_server: str = DNS_SERVER, domain: str = TEST_DOMAIN) -> bool:
    """Check if DNS resolution works."""
    returncode = _run_cmd(["dig", "@" + dns_server, domain, "+time=1", "+tries=1"])
    return returncode == 0


# =============================================================================
# macOS DNS Functions
# =============================================================================


def _macos_get_active_service() -> Optional[str]:
    """Get active network service name on macOS."""
    try:
        result = subprocess.run(
            ["networksetup", "-listallnetworkservices"],
            capture_output=True,
            text=True,
        )
        services = result.stdout.strip().split("\n")
        # Return first non-empty service (usually "Wi-Fi" or "Ethernet")
        for service in services:
            if service and not service.startswith("*"):
                return service
        return None
    except Exception as e:
        logging.error(f"Failed to get active service: {e}")
        return None


def _macos_dns_set(service: str, dns_servers: List[str]) -> None:
    """Set DNS servers for a network service on macOS."""
    cmd = ["networksetup", "-setdnsservers", service] + dns_servers
    _run_cmd(cmd)


def _macos_dns_reset(service: str) -> None:
    """Reset DNS to default (empty) for a network service on macOS."""
    _run_cmd(["networksetup", "-setdnsservers", service, "empty"])


def _macos_dns_get(service: str) -> List[str]:
    """Get current DNS servers for a network service on macOS."""
    try:
        result = subprocess.check_output(
            ["networksetup", "-getdnsservers", service],
            text=True,
        ).strip()

        if "There aren't any DNS Servers set" in result:
            return []

        return result.splitlines()
    except Exception as e:
        logging.error(f"Failed to get DNS: {e}")
        return []


def _macos_dns_clean() -> None:
    """Flush DNS cache on macOS."""
    _run_cmd(["dscacheutil", "-flushcache"])
    _run_cmd(["killall", "-HUP", "mDNSResponder"])


def _macos_dns_is_already_set(service: str, dns_ip: str = DNS_SERVER) -> bool:
    """Check if DNS server is already set."""
    dns_servers = _macos_dns_get(service)
    return dns_ip in dns_servers


# =============================================================================
# Linux DNS Functions
# =============================================================================


def _linux_flush_caches() -> None:
    """Flush DNS caches on Linux."""
    # Check if systemd-resolved is running first
    result = subprocess.run(
        ["systemctl", "is-active", "systemd-resolved.service"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0 or result.stdout.strip() != "active":
        logging.debug("systemd-resolved not running, skip DNS cache flush")
        return

    # Try resolvectl first (systemd 239+)
    if _run_cmd(["resolvectl", "flush"]) == 0:
        logging.debug("Flushed DNS cache via resolvectl")
        return

    # Fallback to systemd-resolve
    if _run_cmd(["systemd-resolve", "--flush-caches"]) == 0:
        logging.debug("Flushed DNS cache via systemd-resolve")
        return

    logging.debug("Could not flush DNS cache")


def _linux_dns_disable() -> None:
    """
    Disable systemd-resolved and set static DNS.
    
    Safety:
    - Only modifies DNS if systemd-resolved is running
    - Falls back to static DNS if systemd-resolved not available
    """
    if not _is_root():
        logging.error("dns:disable requires root privileges on Linux")
        return

    # Check if systemd-resolved is running
    result = subprocess.run(
        ["systemctl", "is-active", "systemd-resolved.service"],
        capture_output=True,
        text=True,
    )
    
    if result.returncode == 0 and result.stdout.strip() == "active":
        # systemd-resolved is running, stop it
        _run_cmd(["systemctl", "stop", "systemd-resolved.service"])
        _run_cmd(["systemctl", "disable", "systemd-resolved.service"])
        logging.debug("Stopped systemd-resolved service")
    else:
        logging.debug("systemd-resolved not running, skipping service stop")

    # Backup existing resolv.conf if it's not already a backup
    if os.path.exists("/etc/resolv.conf") and not os.path.islink("/etc/resolv.conf"):
        # It's a regular file, might already be custom
        pass
    elif os.path.islink("/etc/resolv.conf"):
        # It's a symlink, remove it
        _run_cmd(["rm", "-f", "/etc/resolv.conf"])

    # Write new resolv.conf with static DNS
    resolv_content = f"""# Managed by ductn (dns:disable)
nameserver {STATIC_DNS_SERVERS[0]}
nameserver {STATIC_DNS_SERVERS[1]}
search {SEARCH_DOMAIN}
"""
    try:
        with open("/etc/resolv.conf", "w") as f:
            f.write(resolv_content)
        logging.info("DNS disabled (Linux): static DNS set to %s", STATIC_DNS_SERVERS)
    except Exception as e:
        logging.error(f"Failed to write resolv.conf: {e}")


def _linux_dns_resolved() -> None:
    """
    Re-enable systemd-resolved.
    
    Safety checks:
    1. Verify systemd-resolved is installed and running
    2. Verify symlink target exists before modifying /etc/resolv.conf
    """
    if not _is_root():
        logging.error("dns:resolved requires root privileges on Linux")
        return

    # CHECK 1: Verify systemd-resolved is running
    result = subprocess.run(
        ["systemctl", "is-active", "systemd-resolved.service"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0 or result.stdout.strip() != "active":
        logging.error(
            "systemd-resolved is not running. "
            "Cannot reset DNS to systemd-resolved. "
            "Install with: apt install systemd-resolved"
        )
        return

    # CHECK 2: Verify symlink target exists
    if not os.path.exists("/run/systemd/resolve/resolv.conf"):
        logging.error(
            "systemd-resolved resolv.conf not found at /run/systemd/resolve/resolv.conf. "
            "Cannot reset DNS."
        )
        return

    # Safe to proceed: remove old and create symlink
    _run_cmd(["rm", "-f", "/etc/resolv.conf"])
    _run_cmd([
        "ln", "-sf", "/run/systemd/resolve/resolv.conf", "/etc/resolv.conf"
    ])

    logging.info("DNS reset to systemd-resolved (Linux)")


# =============================================================================
# Cross-Platform Commands
# =============================================================================


@register_command
def d_dns_clean():
    """
    Clear DNS cache.

    - macOS: Flush mDNS cache
    - Linux: Flush systemd-resolved cache
    """
    if SYSTEM == "Darwin":  # macOS
        _macos_dns_clean()
        logging.info("DNS cache flushed (macOS)")

    elif SYSTEM == "Linux":
        _linux_flush_caches()
        logging.info("DNS cache flushed (Linux)")


@register_command
def d_dns_reset():
    """
    Reset DNS to default.

    - macOS: Reset to empty/default DNS
    - Linux: Restore systemd-resolved
    """
    if SYSTEM == "Darwin":  # macOS
        service = _macos_get_active_service()
        if service:
            _macos_dns_reset(service)
            logging.info("DNS reset to default (macOS): %s", service)
        else:
            logging.warning("No active network service found (macOS)")

    elif SYSTEM == "Linux":
        _linux_dns_resolved()
        logging.info("DNS reset to systemd-resolved (Linux)")


@register_command
def d_dns_disable():
    """
    Disable DNS services.

    - Linux: Stop systemd-resolved, set static DNS (1.1.1.1, 8.8.8.8)
    - macOS: Alias for dns:clean + dns:reset (flush cache + reset to default)
    """
    if SYSTEM == "Linux":
        _linux_dns_disable()
        logging.info("DNS disabled (Linux): static DNS set")

    elif SYSTEM == "Darwin":  # macOS
        d_dns_clean()
        d_dns_reset()
        logging.info("DNS disabled (macOS): flushed cache and reset to default")


@register_command
def d_dns_resolved():
    """
    Re-enable DNS services.

    - Linux: Restore systemd-resolved symlink and restart service
    - macOS: Alias for dns:clean + dns:reset (flush cache + reset to default)
    """
    if SYSTEM == "Linux":
        _linux_dns_resolved()
        logging.info("DNS resolved (Linux): systemd-resolved restored")

    elif SYSTEM == "Darwin":  # macOS
        d_dns_clean()
        d_dns_reset()
        logging.info("DNS resolved (macOS): flushed cache and reset to default")


@register_command
def d_dns_watch():
    """
    Auto-watch DNS and fix if needed.

    - macOS: Check connectivity, auto-fix DNS
    - Linux: No-op (systemd-resolved handles DNS automatically)
    """
    if SYSTEM != "Darwin":  # Only run on macOS
        logging.debug("dns:watch skipped on %s (systemd-resolved handles DNS)", SYSTEM)
        return

    if not _is_root():
        logging.debug("dns:watch requires root privileges")
        return

    service = _macos_get_active_service()
    if not service:
        logging.warning("No active network service found (macOS)")
        return

    # Check connectivity and DNS
    if _ping_ok() and _dns_ok():
        if _macos_dns_is_already_set(service):
            logging.info("DNS already set to %s → skip", DNS_SERVER)
            return
        logging.info("DNS OK → switch %s to %s", service, DNS_SERVER)
        _macos_dns_set(service, [DNS_SERVER])
    else:
        logging.warning("DNS FAIL → reset %s to default", service)
        _macos_dns_reset(service)


# Legacy alias for backward compatibility
macos_dns_watch = d_dns_watch
