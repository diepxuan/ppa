#!/usr/bin/env bash
#!/bin/bash

d_route:default() {
    [[ "$1" == "--help" ]] &&
        echo "Lấy NIC mặc định để ra Internet" &&
        return
    # ip r | grep ^default | head -n 1 | grep -oP '(?<=dev )[^ ]*'
    # ip route show default 2>/dev/null | awk 'NR==1 {print $5}'

    # Cách 1: ip route + awk (portable, nhanh)
    nic=$(ip route show default 2>/dev/null | awk 'NR==1 {print $5}')
    if [[ -n "$nic" ]]; then
        echo "$nic"
        return 0
    fi

    # Nếu không có, fallback lấy NIC thật từ ip link
    nic=$(ip -o link show | awk -F': ' '{print $2}' | cut -d'@' -f1 | grep -v -E 'lo|vmbr|tap|vnet|docker|br-'| head -n1)
    if [[ -n "$nic" ]]; then
        echo "$nic"
        return 0
    fi

    # Cách 2: ip r + grep PCRE (chính xác, nhưng cần grep -P)
    if grep -P '' <<< "" >/dev/null 2>&1; then
        nic=$(ip r 2>/dev/null | grep ^default | head -n 1 | grep -oP '(?<=dev )[^ ]*')
        if [[ -n "$nic" ]]; then
            echo "$nic"
            return 0
        fi
    fi

    # Cách 3: route -n (legacy fallback)
    if command -v route >/dev/null 2>&1; then
        nic=$(route -n 2>/dev/null | awk '/^0.0.0.0/ {print $8; exit}')
        if [[ -n "$nic" ]]; then
            echo "$nic"
            return 0
        fi
    fi

    echo "" >&2
    return 1
}

d_route:checkAndUp() {
    [[ "$1" == "--help" ]] &&
        echo "Kiểm tra trạng thái NIC và khởi động nếu cần" &&
        return

    local nic
    nic=$(d_route:default)

    if [[ -z "$nic" ]]; then
        return 1
    fi

    local state
    state=$(cat /sys/class/net/"$nic"/operstate 2>/dev/null)

    if [[ "$state" != "up" ]]; then
        $SUDO ip link set dev "$nic" up
        # sleep 1
        # state=$(cat /sys/class/net/"$nic"/operstate 2>/dev/null)
    fi

    if ! ping -c1 -W2 8.8.8.8 >/dev/null 2>&1; then
        d_route:reload "$nic"
    fi
}

d_route:reload() {
    [[ "$1" == "--help" ]] &&
        echo "Reload lại cấu hình mạng (tương đương 'ip link set dev <nic> down' và 'ip link set dev <nic> up')" &&
        return

    local nic
    nic=${1:-$(d_route:default)}

    if [[ -z "$nic" ]];  then
        return 1
    fi

    if command -v ifreload >/dev/null 2>&1; then
        $SUDO ifreload "$nic"
        return 0
    fi

    if command -v ifdown >/dev/null 2>&1 && command -v ifup >/dev/null 2>&1; then
        $SUDO ifdown "$nic" >/dev/null 2>&1
        $SUDO ifup "$nic" >/dev/null 2>&1
        return 0
    fi

    # if systemctl list-unit-files | grep -q systemd-networkd; then
    #     $SUDO systemctl restart systemd-networkd
    #     return 0
    # fi

    # if systemctl list-unit-files | grep -q NetworkManager; then
    #     $SUDO systemctl restart NetworkManager
    #     return 0
    # fi

    $SUDO ip link set dev "$nic" down >/dev/null 2>&1
    $SUDO ip link set dev "$nic" up >/dev/null 2>&1
    return 0

}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
