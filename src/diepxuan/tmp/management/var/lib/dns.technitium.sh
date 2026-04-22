#!/usr/bin/env bash
#!/bin/bash

d_dns:technitium:install() {
    [[ "$1" == "--help" ]] &&
        echo "Install Technitium dns server" &&
        return
    sudo bash <(curl -fsSL https://download.technitium.com/dns/install.sh)
}

d_dns:technitium:recordList() {
    [[ "$1" == "--help" ]] &&
        echo "Sync record address to Technitium dns server" &&
        return
    curl -s -X POST http://
}

--dns:technitium:get() {
    [[ "$1" == "--help" ]] &&
        echo "Install Technitium dns server" &&
        return
    sudo bash <(curl -fsSL https://download.technitium.com/dns/install.sh)
}

--isenabled() {
    :
    # echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
