#!/usr/bin/env bash
#!/bin/bash

_main() {
    if groups | grep "\<sudo\>" &>/dev/null; then
        --echo "----------------------------------------------------------------------"
        --echo "\tDiepXuan Management - configuration VMs automation"
        --echo "----------------------------------------------------------------------"
        --echo "  [$Green✓$NC] Root user check"
    else
        --echo "  [$Red✗$NC] Root user check"
        exit 1
    fi

    --echo "  [i] List all domains"
    domains=()
    hosts=()
    for domain in $(--sys:env:domains); do
        ip=$(--host:address $domain)
        [[ $ip == $(--ip:local) ]] && continue

        host=$(--ssh $domain 'ductn host:fullname')
        [[ ! " ${hosts[*]} " =~ " ${host} " ]] && domains+=($domain) && hosts+=($host) || continue

        ver=$(--ssh $domain 'ductn -v')
        [[ ! $ver < $(--version) ]] && ver="$Green$ver$NC" || ver="$Red$ver$NC"

        --echo "  [$Green✓$NC] $domain"
        --echo "    $host"
        --echo "    $ip"
        --echo "    $ver"

        unset ip host ver
    done

    --echo "----------------------------------------------------------------------"
    --echo "  [i] VPN installed check:"
    vpn_installing=()
    for i in ${!domains[@]}; do
        domain=${domains[$i]}
        host=${hosts[$i]}
        if [[ $(--vpn:wireguard:is_exist $domain) == 0 ]]; then
            vpn_installing+=($i)
            --echo "    [$Red✗$NC] $host Wireguard not found"
        else
            --echo "    [$Green✓$NC] $host Wireguard installed"
        fi
        unset domain host
    done

    if [[ ${#vpn_installing[@]} > 0 ]]; then
        --echo "  [i] VPN installing"
        for index in ${vpn_installing[@]}; do
            host=${hosts[$index]}
            domain=${domains[$index]}
            [[ $(--host:is_server $host) == 1 ]] && --vpn:wireguard:install $domain
            [[ $(--host:is_vpn_server $host) == 1 ]] && --vpn:wireguard:install $domain
        done
    fi

    unset vpn_installing

    --echo "\r\n  [i] VPN config check:"
    --echo "    [i] VPN keys"
    for i in ${!domains[@]}; do
        domain=${domains[$i]}
        host=${hosts[$i]}

        [[ $(--host:is_server $host) == 1 ]] || [[ $(--host:is_vpn_server $host) == 1 ]] || continue

        --ssh $domain "[[ ! -d $WIREGUARD_KEYDIR ]] && sudo mkdir -p $WIREGUARD_KEYDIR"
        key_exist=$(--ssh $domain "[[ -n \$(sudo cat $WIREGUARD_KEYDIR/server_private.key) ]] && echo 1 || echo 0")
        [[ $key_exist == 1 ]] && --echo "    [$Green✓$NC] $host"

        [[ $key_exist == 1 ]] || --echo "    [$Red✗$NC] $host missing keys, regen keys"
        [[ $key_exist == 1 ]] || --ssh $domain "wg genkey | sudo tee $WIREGUARD_KEYDIR/server_private.key | wg pubkey | sudo tee $WIREGUARD_KEYDIR/server_public.key >/dev/null"

        --echo "\t$(--ssh $domain "sudo cat $WIREGUARD_KEYDIR/server_private.key")"
        --echo "\t$(--ssh $domain "sudo cat $WIREGUARD_KEYDIR/server_public.key")"

        unset domain host key_exist
    done

    --echo "\r\n    [i] VPN configs"

    for i in ${!domains[@]}; do
        domain=${domains[$i]}
        host=${hosts[$i]}
        ip=$(--host:address $domain)

        [[ ! $(--host:is_vpn_server $host) == 1 ]] && continue

        is_exist=$(--ssh $domain "[[ -n \$(sudo cat $WIREGUARD_CONFIG) ]] && echo 1 || echo 0")
        [[ $is_exist == 1 ]] && --echo "    [$Green✓$NC] $host configuration exist ($WIREGUARD_CONFIG)"
        [[ $is_exist == 1 ]] || --echo "    [$Red✗$NC] $host configuration missing"

        pri_key=$(--ssh $domain "sudo cat $WIREGUARD_KEYDIR/server_private.key")
        pub_key=$(--ssh $domain "sudo cat $WIREGUARD_KEYDIR/server_public.key")
        serial=$(--ssh $domain "ductn host:serial")

        if [[ ! $is_exist == 1 ]]; then

            --ssh $domain "sudo touch $WIREGUARD_CONFIG"
            cat <<EOF | --ssh $domain "sudo tee $WIREGUARD_CONFIG" >/dev/null
[Interface]
ListenPort = $WIREGUARD_PORT
PrivateKey = $pri_key
Address = 10.8.$serial.254/24
EOF
            is_exist=$(--ssh $domain "[[ -n \$(sudo cat $WIREGUARD_CONFIG) ]] && echo 1 || echo 0")
            [[ $is_exist == 1 ]] && --echo "      [$Green✓$NC] $host configuration exist ($WIREGUARD_CONFIG)"
            [[ $is_exist == 1 ]] && --ssh $domain "wg-quick down $WIREGUARD_IFACE"
            [[ $is_exist == 1 ]] && --ssh $domain "sudo systemctl enable wg-quick@$WIREGUARD_IFACE"
            [[ $is_exist == 1 ]] || --echo "      [$Red✗$NC] $host configuration missing"
        fi

        is_exist=$(--ssh $domain "ip r show 10.8.2.0/24 | wc -l")
        [[ $is_exist > 0 ]] && --echo "    [$Green✓$NC] $host wireguard running"
        [[ $is_exist > 0 ]] || --echo "    [$Red✗$NC] $host wireguard is stoped"

        if [[ ! $is_exist > 0 ]]; then
            [[ $is_exist > 0 ]] || --echo "    [i] $host wireguard is starting"
            [[ $is_exist > 0 ]] || --ssh $domain "sudo systemctl restart wg-quick@$WIREGUARD_IFACE"

            is_exist=$(--ssh $domain "ip r show 10.8.2.0/24 | wc -l")

            [[ $is_exist > 0 ]] && --echo "    [$Green✓$NC] $host wireguard running"
            [[ $is_exist > 0 ]] || --echo "    [$Red✗$NC] $host wireguard is stoped"
        fi

        for i in ${!domains[@]}; do
            client_domain=${domains[$i]}
            client_host=${hosts[$i]}
            client_ip=$(--host:address $client_domain)

            [[ ! $(--host:is_server $client_host) == 1 ]] && continue
            # [[ $client_host =~ ^pve1 ]] && continue

            is_exist=$(--ssh $client_domain "[[ -n \$(sudo cat $WIREGUARD_CONFIG) ]] && echo 1 || echo 0")
            [[ $is_exist == 1 ]] && --echo "      [$Green✓$NC] $client_host configuration exist ($WIREGUARD_CONFIG)"
            [[ $is_exist == 1 ]] || --echo "      [$Red✗$NC] $client_host configuration missing"

            client_pri_key=$(--ssh $client_domain "sudo cat $WIREGUARD_KEYDIR/server_private.key")
            client_pub_key=$(--ssh $client_domain "sudo cat $WIREGUARD_KEYDIR/server_public.key")
            client_serial=$(--ssh $client_domain "ductn host:serial")

            if [[ ! $is_exist == 1 ]]; then

                --echo "      [i] $client_host wireguard is configurating"
                --ssh $client_domain "sudo touch $WIREGUARD_CONFIG"
                cat <<EOF | --ssh $client_domain "sudo tee $WIREGUARD_CONFIG" >/dev/null
[Interface]
ListenPort = $WIREGUARD_PORT
PrivateKey = $client_pri_key
Address = 10.8.$serial.$client_serial/24
EOF
                is_exist=$(--ssh $client_domain "[[ -n \$(sudo cat $WIREGUARD_CONFIG) ]] && echo 1 || echo 0")
                [[ $is_exist == 1 ]] && --echo "      [$Green✓$NC] $client_host configuration exist ($WIREGUARD_CONFIG)"
                [[ $is_exist == 1 ]] && --ssh $client_domain "wg-quick down $WIREGUARD_IFACE"
                [[ $is_exist == 1 ]] && --ssh $client_domain "sudo systemctl enable wg-quick@$WIREGUARD_IFACE"
                [[ $is_exist == 1 ]] || --echo "      [$Red✗$NC] $client_host configuration missing"
            fi

            is_exist=$(--ssh $client_domain "ip r show 10.8.2.0/24 | wc -l")
            [[ $is_exist > 0 ]] && --echo "      [$Green✓$NC] $client_host wireguard running"
            [[ $is_exist > 0 ]] || --echo "      [$Red✗$NC] $client_host wireguard is stoped"

            if [[ ! $is_exist > 0 ]]; then
                [[ $is_exist > 0 ]] || --echo "      [i] $client_host wireguard is starting"
                [[ $is_exist > 0 ]] || --ssh $client_domain "sudo systemctl restart wg-quick@$WIREGUARD_IFACE"

                is_exist=$(--ssh $client_domain "ip r show 10.8.2.0/24 | wc -l")

                [[ $is_exist > 0 ]] && --echo "      [$Green✓$NC] $client_host wireguard running"
                [[ $is_exist > 0 ]] || --echo "      [$Red✗$NC] $client_host wireguard is stoped"
            fi

            # Usage: wg set <interface> [listen-port <port>] [fwmark <mark>] [private-key <file path>] [peer <base64 public key> [remove] [preshared-key <file path>] [endpoint <ip>:<port>] [persistent-keepalive <interval seconds>] [allowed-ips <ip1>/<cidr1>[,<ip2>/<cidr2>]...] ]...
            --echo "      [i] $host allow connect from peer $client_host"
            --ssh $domain "sudo wg set $WIREGUARD_IFACE peer $client_pub_key allowed-ips 10.8.$serial.$client_serial"

            --echo "      [i] $client_host connect to $host"
            # --ssh $client_domain "sudo wg set $WIREGUARD_IFACE peer $pub_key endpoint $ip:$WIREGUARD_PORT persistent-keepalive 15 allowed-ips 10.8.$serial.0/24"
            [[ $serial == $client_serial ]] && --ssh $client_domain "sudo wg set $WIREGUARD_IFACE peer $pub_key endpoint $ip:$WIREGUARD_PORT persistent-keepalive 15 allowed-ips 10.8.$serial.254/32 0.0.0.0/0"
            [[ $serial == $client_serial ]] || --ssh $client_domain "sudo wg set $WIREGUARD_IFACE peer $pub_key endpoint $ip:$WIREGUARD_PORT persistent-keepalive 15 allowed-ips 10.8.$serial.0/24"

            --ssh $domain "wg-quick save $WIREGUARD_IFACE"
            --ssh $client_domain "wg-quick save $WIREGUARD_IFACE"

            unset client_domain client_host client_ip is_exist client_pri_key client_pub_key client_serial
        done

        unset domain host ip is_exist pri_key pub_key serial
    done
}
