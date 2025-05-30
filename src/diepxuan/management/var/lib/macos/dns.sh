#!/usr/bin/env bash
#!/bin/bash

d_dns:status() {
    [[ "$1" == "--help" ]] &&
        echo "Get DNS status" &&
        return
    if [[ -x "$(command -v dig)" ]]; then
        $SUDO dig status
    else
        echo "DNS tools are not installed."
    fi
}

d_dns:set() {
    [[ "$1" == "--help" ]] &&
        echo "Set DNS name server" &&
        return
    # services=$(networksetup -listallnetworkservices | tail -n +2)

    DNS=$@
    DNS=${DNS:-"8.8.8.8, 1.1.1.1"}

    while IFS= read -r service; do
        $SUDO networksetup -setdnsservers $service $DNS
    done <<<$(networksetup -listallnetworkservices | tail -n +2)
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
