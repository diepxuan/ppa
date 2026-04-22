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
    # Kiểm tra từng IP DNS, chỉ giữ lại IP sống
    VALID_DNS=""
    for ip in $DNS; do
        if ping -c 1 -W 1 "$ip" &>/dev/null; then
            VALID_DNS+="$ip "
        else
            echo "⚠️ DNS $ip unreachable, skipping..."
        fi
    done
    # Nếu không IP nào sống, đặt là "Empty"
    VALID_DNS=${VALID_DNS:-"Empty"}
    DNS=${DNS:-"Empty"}

    while IFS= read -r service; do
        $SUDO networksetup -setdnsservers $service $VALID_DNS || {
            echo "Failed to set DNS for $service"
            continue
        }
    done < <(networksetup -listallnetworkservices | tail -n +2)
}

d_dns:clean() {
    [[ "$1" == "--help" ]] &&
        echo "Clean DNS name server" &&
        return

    $SUDO dscacheutil -flushcache
    $SUDO killall -HUP mDNSResponder
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
