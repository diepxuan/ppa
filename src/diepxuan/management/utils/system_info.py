import platform

from .registry import register_command
from . import distro


def _os_codename():
    """Get OS codename"""
    return distro.codename()


@register_command
def d_os_codename():
    """Get OS codename"""
    print(_os_codename())


def _os_release():
    """Get OS release"""
    return distro.version()


@register_command
def d_os_release():
    """Get OS release"""
    print(_os_release())


def _os_distro():
    """Get OS distro"""
    return distro.id()


@register_command
def d_os_distro():
    """Get OS distro"""
    print(_os_distro())


def _os_architecture():
    """Get OS architecture"""
    return platform.machine()


@register_command
def d_os_architecture():
    """Get OS architecture"""
    print(_os_architecture())


@register_command
def d_os_type():
    """Get OS type"""
    print(platform.system())
