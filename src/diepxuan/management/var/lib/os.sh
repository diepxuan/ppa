#!/usr/bin/env bash
#!/bin/bash

d_os:CODENAME() {
    [[ "$OSTYPE" == "darwin"* ]] &&
        CODENAME=$(sw_vers -productVersion | awk -F '.' '{print $1"."$2}')
    [[ -f /etc/os-release ]] && . /etc/os-release
    [[ -f /etc/lsb-release ]] && . /etc/lsb-release
    CODENAME=${CODENAME:-$DISTRIB_CODENAME}
    CODENAME=${CODENAME:-$VERSION_CODENAME}
    CODENAME=${CODENAME:-$UBUNTU_CODENAME}
    CODENAME=${CODENAME:-"unknown"}
    echo "$CODENAME"
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
