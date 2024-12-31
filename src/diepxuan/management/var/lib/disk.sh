#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:disk:check")
--sys:disk:check() {
    --sys:disk:check8k
    --sys:disk:check512k
}

_DUCTN_COMMANDS+=("sys:disk:check8k")
--sys:disk:check8k() {
    dd if=/dev/zero of=/tmp/output bs=8k count=10k
    rm -f /tmp/output
}

_DUCTN_COMMANDS+=("sys:disk:check512k")
--sys:disk:check512k() {
    dd if=/dev/zero of=/tmp/output bs=512k count=1k
    rm -f /tmp/output
}

--zfs:disk:list() {
    ls -alh /dev/disk/by-id/
    sudo zpool status
    sudo zpool list -v
}

--zfs:disk:offline() {
    # sudo zpool offline "POOLNAME" "HARD-DRIVE-ID or the whole path"
    # sudo zpool offline rpool ata-HITACHI_HUA722010ALA330_J80TS2LL
    sudo zpool offline rpool $@
}

--zfs:disk:replace() {
    sudo proxmox-boot-tool status
}
--zfs:disk:replace_disk() {
    --logger "replace_disk $_pool_name $_old_zfs_part $_new_zfs_part"
    _pool_name=$1
    _old_zfs_part=$2
    _new_zfs_part=$3
    sudo zpool replace -f $_pool_name $_old_zfs_part $_new_zfs_part
}

--zfs:disk:replace_boot_disk() {
    --logger "replace_boot_disk"
    # Copying the partition table, reissuing GUIDs and replacing the ZFS partition are the same.
    # To make the system bootable from the new disk, different steps are needed which depend on the bootloader in use.

    # sudo sgdisk /dev/disk/by-id/ata-TOSHIBA_MQ01ABD100_48MFT0FZT -R /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR100XBN1LH00E
    # sudo sgdisk -G /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR100XBN1LH00E
    # sudo zpool replace -f rpool /dev/disk/by-id/ata-HITACHI_HUA722010ALA330_J80TS2LL-part3 /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR100XBN1LH00E-part3
}

--zfs:disk:format_boot_disk() {
    --logger "format_boot_disk"
    # ESP stands for EFI System Partition, which is setup as partition #2 on bootable disks setup by the Proxmox

    # sudo proxmox-boot-tool format /dev/sdb2
}
