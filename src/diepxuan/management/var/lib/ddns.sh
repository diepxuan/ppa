#!/usr/bin/env bash
#!/bin/bash

d_ddns:bind9:install() {
    [[ "$1" == "--help" ]] &&
        echo "Install bind9 dns server" &&
        return
    sudo apt-get install -y bind9
    sudo systemctl enable bind9.service
    sudo systemctl start bind9.service
}

--dns:disable() {
    sudo systemctl stop systemd-resolved.service
    sudo systemctl disable systemd-resolved.service
    sudo rm -rf /etc/resolv.conf
    cat <<EOF | sudo tee /etc/resolv.conf
# This file is managed by man:systemd-resolved(8). Do not edit.
#
# This is a dynamic resolv.conf file for connecting local clients directly to
# all known uplink DNS servers. This file lists all configured search domains.
#
# Third party programs should typically not access this file directly, but only
# through the symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a
# different way, replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.

nameserver 1.1.1.1
nameserver 8.8.8.8
search diepxuan.com
EOF
}

d_ddns:resolved() {
    [[ "$1" == "--help" ]] &&
        echo "Revert system resolved" &&
        return
    sudo rm -rf /etc/resolv.conf
    sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    sudo systemctl enable systemd-resolved.service
    sudo systemctl restart systemd-resolved.service
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
