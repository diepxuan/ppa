#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("csf:config")
--csf() {
    --csf:install
    --csf:config
}

_DUCTN_COMMANDS+=("csf:install")
--csf:install() {
    --sys:ufw:disable

    curl http://download.configserver.com/csf.tgz -o /tmp/ductn/csf.tgz
    tar -xzf /tmp/ductn/csf.tgz -C /tmp/ductn

    cd /tmp/ductn/csf && sudo sh install.sh

    [[ -n $(command -v iptables) ]] && [[ $(which iptables) != /sbin/iptables ]] && [[ ! -f /sbin/iptables ]] && sudo ln $(which iptables) /sbin/iptables
    [[ -n $(command -v iptables-save) ]] && [[ $(which iptables-save) != /sbin/iptables-save ]] && [[ ! -f /sbin/iptables-save ]] && sudo ln $(which iptables-save) /sbin/iptables-save
    [[ -n $(command -v iptables-restore) ]] && [[ $(which iptables-restore) != /sbin/iptables-restore ]] && [[ ! -f /sbin/iptables-restore ]] && sudo ln $(which iptables-restore) /sbin/iptables-restore
}

_DUCTN_COMMANDS+=("csf:config")
--csf:config() {
    while IFS= read -r cnf; do
        [[ -z $cnf ]] && continue
        param=${cnf% = *}
        value=${cnf#* = }
        value=${value//\"/}
        --csf:config:set $param $value
    done < <(--sys:env:csf)

    [[ -f /etc/csf/csfpost.sh ]] || sudo touch /etc/csf/csfpost.sh
    echo "$(_csf_rules)" | sudo tee /etc/csf/csfpost.sh

    while read -r domain; do
        [[ -z $domain ]] && continue
        [[ -n $(sudo grep -P $domain /etc/csf/csf.dyndns) ]] || echo -e $domain | sudo tee -a /etc/csf/csf.dyndns >/dev/null
    done < <(--sys:env:domains)

    # Restart firewall rules (csf) and then restart lfd daemon
    sudo csf -ra
}

_DUCTN_COMMANDS+=("csf:config:set")
--csf:config:set() {
    param=$1
    value=$2
    sudo sed -i "s|$param = .*|$param = \"$value\"|" /etc/csf/csf.conf
}

_csf_rules() {
    INET_IP="$(--ip:wan)"
    # INET_IFACE="$(sudo route | grep '^default' | head -1 | grep -o '[^ ]*$')"
    # INET_IFACE=$(ip r | grep default | head -n 1 | grep -oP '(?<=dev )[^ ]*')
    INET_IFACE="$(--route:default)"

    LAN_IP="$(--ip:local)"
    LAN_SUB="$(--ip:subnet)"
    LAN_IFACE="vmbr1"

    LO_IFACE="lo"
    LO_IP="127.0.0.1"

    echo "iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1"
    echo "iptables -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE"

    if [[ "$(ip r | grep $LAN_IFACE)" != "" ]]; then
        echo "# iptables -t nat -A POSTROUTING -o $LAN_IFACE -j MASQUERADE"

        echo "iptables -A INPUT -i $LAN_IFACE -j ACCEPT"
        echo "iptables -A FORWARD -i $LAN_IFACE -j ACCEPT"
        echo "iptables -A FORWARD -o $LAN_IFACE -j ACCEPT"

        # allow traffic from internal to DMZ
        echo "iptables -A FORWARD -i $INET_IFACE -o $LAN_IFACE -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT"
        echo "iptables -A FORWARD -i $LAN_IFACE -o $INET_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"

        for address in $(--sys:env:nat); do
            tcp=$(--sys:env:nat $address tcp)
            udp=$(--sys:env:nat $address udp)

            # redirect incoming requests at INET_IP of FIREWALL to server DMZ
            [[ -n $address ]] && [[ -n $tcp ]] && echo "iptables -t nat -A PREROUTING -i $INET_IFACE -p TCP -m multiport --dport $tcp -j DNAT --to-destination $address"
            [[ -n $address ]] && [[ -n $udp ]] && echo "iptables -t nat -A PREROUTING -i $INET_IFACE -p UDP -m multiport --dport $udp -j DNAT --to-destination $address"

            unset tcp udp
        done
    fi

    # # Enable simple IP Forwarding and Network Address Translation
    # echo "-t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP"
}

--csf:regex() {
    regex=$(curl -o - https://diepxuan.github.io/ppa/usr/regex.custom.pm?$RANDOM 2>/dev/null)
    regex_old=$(sudo cat /usr/local/csf/bin/regex.custom.pm)
    [[ -n $regex ]] && [[ ! $regex_old == $regex ]] && echo "$regex" | sudo tee /usr/local/csf/bin/regex.custom.pm >/dev/null
    unset regex regex_old
}
