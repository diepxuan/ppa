import subprocess
import logging
import shutil
from . import register_command
from .system import _is_root

DNS_SERVER = "10.0.0.103"
TEST_DOMAIN = "google.com"


def ping_ok():
    return (
        subprocess.call(
            ["ping", "-c", "1", "-W", "1000", DNS_SERVER],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        == 0
    )


def dns_ok():
    return (
        subprocess.call(
            ["dig", "@" + DNS_SERVER, "google.com", "+time=1", "+tries=1"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        == 0
    )


def clear_dns(service):
    subprocess.check_call(["networksetup", "-setdnsservers", service, "Empty"])


def set_dns(service, dns=DNS_SERVER):
    subprocess.run(
        ["networksetup", "-setdnsservers", service, dns],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def reset_dns(service):
    subprocess.run(
        ["networksetup", "-setdnsservers", service, "empty"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


@register_command
def d_dns_reset():
    """Trả về DNS Mac Dinh."""
    reset_dns(get_active_service())


def get_dns(service):
    out = subprocess.check_output(
        ["networksetup", "-getdnsservers", service],
        text=True,
    ).strip()

    if "There aren't any DNS Servers set" in out:
        return []

    return out.splitlines()


def dns_is_already_set(service, dns_ip=DNS_SERVER):
    dns = get_dns(service)
    return dns_ip in dns


import logging
from .interface import get_active_service


def macos_dns_watch():
    if not _is_root():
        return
    logging.info("macos_dns_watch")
    service = get_active_service()
    if not service:
        logging.warning("No active network service found")
        return

    if dns_is_already_set(service):
        logging.info("DNS already set to 10.0.0.103 → skip")
        return

    if ping_ok() and dns_ok():
        logging.info(f"DNS OK → switch {service} to 10.0.0.103")
        set_dns(service=service)
    else:
        logging.warning(f"DNS FAIL → reset {service} to default")
        clear_dns(service)
