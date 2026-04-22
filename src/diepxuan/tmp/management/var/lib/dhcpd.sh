#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:dhcp:setup")
--sys:dhcp:setup() {
    if [ $(--host:is_server) = 1 ]; then
        --sys:apt:install isc-dhcp-server

        --sys:dhcp:config
    fi
}

--sys:dhcp:config() {
    if [[ $(--host:is_server) == 1 ]]; then
        _DHCP_DEFAULT=/etc/default/isc-dhcp-server
        serial=$(--host:serial)

        ### /etc/default/isc-dhcp-server
        sudo sed -i 's/INTERFACES=.*/INTERFACES="vmbr1"/' $_DHCP_DEFAULT >/dev/null
        sudo sed -i 's/INTERFACESv4=.*/INTERFACESv4="vmbr1"/' $_DHCP_DEFAULT >/dev/null
        # sudo sed -i 's/INTERFACESv6=.*/INTERFACESv6="vmbr1"/' $_DHCP_DEFAULT >/dev/null

        ### /etc/dhcp/dhcpd.conf
        [ ! -f /etc/dhcp/dhcpd.conf.org ] && sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.org

        dhcpd_config=${_DHCPD_CONF//'.pve.'/".$serial."}

        for vm_name in $(--sys:env:dhcp); do
            vm_mac=$(--sys:env:dhcp $vm_name mac)
            vm_address=$(--sys:env:dhcp $vm_name address)

            dhcpd_config+="
host $vm_name {
    hardware ethernet $vm_mac;
    fixed-address $vm_address;
    option host-name \"$vm_name\";
}

"
            unset vm_mac vm_address
        done

        echo -e "$dhcpd_config" | sudo tee /etc/dhcp/dhcpd.conf >/dev/null

        sudo killall dhcpd
        sudo rm -rf /var/run/dhcpd.pid
        --sys:service:restart isc-dhcp-server

        unset _DHCP_DEFAULT serial dhcpd_config
    fi
}
_DHCPD_CONF="option domain-name \"diepxuan.com\";
option domain-search \"diepxuan.com\";
option domain-name-servers 171.244.62.193,1.1.1.1, 8.8.8.8;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;
authoritative;

one-lease-per-client true;
deny duplicates;
update-conflict-detection false;

subnet 10.0.pve.0 netmask 255.255.255.0 {
    pool {
        option domain-name-servers 171.244.62.193,1.1.1.1,10.0.1.10,10.0.2.10;
        range 10.0.pve.150 10.0.pve.199;
    }

    option domain-name-servers 171.244.62.193,1.1.1.1,10.0.1.10,10.0.2.10;

    option routers 10.0.pve.1;
    option subnet-mask 255.255.255.0;

    ping-check true;
}

"
