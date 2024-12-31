#!/usr/bin/env bash
#!/bin/bash

--pve:vm() {
    --sys:apt:install qemu-guest-agent
}

# CSRF_TOKEN=

_vm:send() {
    local pri_host=$(--ip:localAll)
    local pub_host=$(--ip:wan)
    local version=$(--version)
    local wgkey=$(--vpn:wireguard:keygen)
    local gateway=$(--ip:gateway && --ip:subnet)

    local vm_info=$(
        cat <<EOF
{
    "pri_host":"$pri_host",
    "pub_host":"$pub_host",
    "gateway":"$gateway",
    "version":"$version",
    "wg_key":"$wgkey"
}
EOF
    )

    _vm:send_ $vm_info
    # --logger $vm_info
}

_vm:send_() {
    local vm_info='{}'
    [[ -n $* ]] && vm_info=$*
    local vm_id=$(--host:fullname)

    local CSRF_TOKEN=$(curl -o - $BASE_URL/vm 2>/dev/null)

    local vm_commands=$(
        curl -s -X PATCH $BASE_URL/vm/$vm_id \
            -H "Content-Type: application/json" \
            -H "X-CSRF-TOKEN: $CSRF_TOKEN" \
            --data "$vm_info"
    )
    _vm:command "$vm_commands"
}

_vm:command() {
    while read -r vm_cmd; do
        $vm_cmd
    done < <(echo $@ | jq -r '.vm.commands[]')
}
