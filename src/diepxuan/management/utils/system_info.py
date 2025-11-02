#!/usr/bin/python3

import os
import re

from .registry import register_command

from .libsysinfo import disk
from .libsysinfo.memstats import MemoryStats

from datetime import datetime
import time
import socket
import subprocess

# import netinfo
import psutil

NIC_BLACKLIST = "lo"


def get_nics() -> list[tuple[str, str]]:
    nics = []

    for ifname, addrs in psutil.net_if_addrs().items():
        if ifname in NIC_BLACKLIST:
            continue

        for addr in addrs:
            if addr.family == 2 and addr.address:  # AF_INET = 2
                stats = psutil.net_if_stats().get(ifname)
                if stats and stats.isup:
                    nics.append((ifname, addr.address))
                    break

    # for ifname in netinfo.get_ifnames():
    #     if ifname in NIC_BLACKLIST:
    #         continue

    #     nic = netinfo.InterfaceInfo(ifname)
    #     if nic.is_up and nic.address:
    #         nics.append((ifname, nic.address))

    nics.sort()
    return nics


def get_loadavg() -> float:
    return os.getloadavg()[0]


def get_pids() -> list[int]:
    return [int(dentry) for dentry in os.listdir("/proc") if re.match(r"\d+$", dentry)]


def get_time_date() -> str:
    timezone = time.strftime("%Z", time.localtime())
    tz_info = f'(UTC{time.strftime("%z", time.localtime())})'
    if timezone != "UTC":
        tz_info = f"- {timezone} {tz_info}"
    time_string = f"%a %b %d %H:%M:%S %Y {tz_info}"
    return datetime.now().strftime(time_string)


@register_command
def d_sys_info():
    system_load = f"System load:  {get_loadavg():.2f}"

    processes = f"Processes:    {len(get_pids())}"
    disk_usage = f"Usage of:     {disk.usage('/')}"

    memstats = MemoryStats()

    memory_usage = "Memory usage:  {:.1f}%".format(memstats.used_memory_percentage)
    swap_usage = "Swap usage:    {:.1f}%".format(memstats.used_swap_percentage)

    rows = []
    rows.append((system_load, memory_usage))
    rows.append((processes, swap_usage))

    all_nics = get_nics()
    if not all_nics:
        nics = ["Networking not configured"]
    else:
        nics = [f"IP address for {nic}: {address}" for nic, address in all_nics]

    column = [disk_usage]
    if nics:
        column.append(nics[0])
    rows.append(column)
    for nic in nics[1:]:
        rows.append(("", nic))

    welcome = socket.gethostname().capitalize()
    print(f"System information for {welcome}")
    print(f"  {get_time_date()}")
    print()
    max_col = max([len(row[0]) for row in rows])
    tpl = "  {:<{col}}   {}"
    for row in rows:
        print(tpl.format(row[0], row[1], col=max_col))
