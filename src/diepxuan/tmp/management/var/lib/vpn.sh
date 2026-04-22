#!/usr/bin/env bash
#!/bin/bash

WIREGUARD_IFACE=wg0
WIREGUARD_PORT=17691
WIREGUARD_CONFIG=/etc/wireguard/$WIREGUARD_IFACE.conf
WIREGUARD_KEYDIR=/etc/wireguard/keys

--vpn:wireguard:is_exist() {
    if [[ -z $@ ]]; then
        [[ -f /usr/bin/wg ]] && echo 1 || echo 0
    else
        --ssh $@ "[[ -f /usr/bin/wg ]] && echo 1 || echo 0"
    fi
}

--vpn:wireguard:install() {
    if [[ -z $@ ]]; then
        --sys:apt:remove openvpn
        --sys:apt:install wireguard resolvconf
    else
        --ssh $@ "ductn sys:apt:remove openvpn"
        --ssh $@ "ductn sys:apt:install wireguard"
    fi
}

--vpn:wireguard:keygen() {
    [ ! -d $WIREGUARD_KEYDIR ] && sudo mkdir -p $WIREGUARD_KEYDIR
    [[ $(--file:chmod $WIREGUARD_KEYDIR) == 755 ]] || sudo chmod 755 $WIREGUARD_KEYDIR

    [[ $(--vpn:wireguard:is_exist) == 1 ]] || return

    sudo touch $WIREGUARD_KEYDIR/server_private.key
    sudo touch $WIREGUARD_KEYDIR/server_public.key

    if [ -z $(sudo cat $WIREGUARD_KEYDIR/server_private.key) ]; then
        wg genkey | sudo tee $WIREGUARD_KEYDIR/server_private.key | wg pubkey | sudo tee $WIREGUARD_KEYDIR/server_public.key >/dev/null
    else
        if [ -z $(sudo cat $WIREGUARD_KEYDIR/server_public.key) ]; then
            sudo cat $WIREGUARD_KEYDIR/server_private.key | wg pubkey | sudo tee $WIREGUARD_KEYDIR/server_public.key >/dev/null
        fi
    fi

    --file:chmod:dirs 755 $WIREGUARD_KEYDIR
    --file:chmod:files 644 $WIREGUARD_KEYDIR

    sudo cat $WIREGUARD_KEYDIR/server_private.key
    sudo cat $WIREGUARD_KEYDIR/server_public.key
}

--vpn:wireguard:reload() {
    wg-quick down $WIREGUARD_IFACE
    sudo systemctl stop wg-quick@$WIREGUARD_IFACE

    wg0=$(--sys:env:vpn)

    if [[ -z "$wg0" ]]; then
        sudo systemctl disable wg-quick@$WIREGUARD_IFACE
        return
    fi

    echo "$wg0" | sudo tee $WIREGUARD_CONFIG >/dev/null

    sudo systemctl enable wg-quick@$WIREGUARD_IFACE
    sudo systemctl restart wg-quick@$WIREGUARD_IFACE
    wg-quick up $WIREGUARD_IFACE

    return
}

--vpn:openvpn:uninstall() {
    --sys:apt:remove openvpn
}
--vpn:type() {
    if [[ "$(--host:domain)" == "diepxuan.com" ]]; then
        echo "client"
    elif [[ "$(--host:domain)" == "vpn" ]]; then
        echo "server"
    else
        echo "none"
    fi
}

--vpn:wireguard:example() {
    function gen_keys() {
        # gen server keys
        if [ ! -f "${KEYS_DIR}/server_private.key" ]; then
            echo "Generating server keys: "
            wg genkey | tee "${KEYS_DIR}/server_private.key" | wg pubkey >"${KEYS_DIR}/server_public.key"
        else
            echo "The Server key already exists: $KEYS_DIR/server_private.key"
            echo "Please remove it and try again!"
            exit
        fi

        # gen client keys
        for i in $(seq 1 $MAX_CLIENTS); do
            client_name="client${i}"
            if [ ! -f "$KEYS_DIR/$client_name" ]; then
                echo "Generating client keys: $client_name"
                wg genkey | tee "${KEYS_DIR}/${client_name}_private.key" | wg pubkey >"${KEYS_DIR}/${client_name}_public.key"
            else
                echo "Client already exists: $client_name"
                echo "Please remove it and try again!"
                exit
            fi
        done
    }

    function gen_server_config() {
        # backup current config if exists
        if [ -f "$SERVER_CONFIG" ]; then
            mv "$SERVER_CONFIG" "${SERVER_CONFIG}_$(date +%s)"
        fi

        server_pri_key=$(cat "${KEYS_DIR}/server_private.key")

        # Check default gateway device interface name
        if [[ -z "${DEVICE}" ]]; then
            if [[ "$(ip r | grep default | wc -l)" -gt 1 ]]; then
                echo "WARN: variable DEVICE is missing or you have more than one default route with multiple priority metrics. Please recheck and rerun."
                sleep 5
            else
                DEVICE=$(ip r | grep default | head -n 1 | grep -oP '(?<=dev )[^ ]*')
            fi
        fi

        # Server base config
        cat >$SERVER_CONFIG <<EOF
[Interface]
PrivateKey =  $server_pri_key
Address = ${TUNNEL_ADDR_PREFIX}.254/24
SaveConfig = true
ListenPort = ${SERVER_PORT}
PostUp = $IPT -A FORWARD -i wg0 -j ACCEPT; $IPT -t nat -A POSTROUTING -s ${TUNNEL_ADDR_PREFIX}.0/24 -o ${DEVICE} -j MASQUERADE
PostDown = $IPT -D FORWARD -i wg0 -j ACCEPT; $IPT -t nat -D POSTROUTING -s ${TUNNEL_ADDR_PREFIX}.0/24 -o ${DEVICE} -j MASQUERADE
EOF

        # Append client config to server
        for i in $(seq 1 $MAX_CLIENTS); do
            client_name="client${i}"
            if [ -f "${KEYS_DIR}/${client_name}_public.key" ]; then
                client_pub_key=$(cat ${KEYS_DIR}/${client_name}_public.key)
                cat >>$SERVER_CONFIG <<EOF
[Peer]
PublicKey = $client_pub_key
AllowedIPs = $TUNNEL_ADDR_PREFIX.$i
EOF
            else
                echo "Client key not found: $client_name"
            fi
        done

        chmod 600 "$SERVER_CONFIG"

    }

    function gen_client_config() {
        for i in $(seq 1 $MAX_CLIENTS); do
            client_name="client${i}"
            if [ ! -f "$KEYS_DIR/${client_name}_private.key" ]; then
                echo "[WARN] Client key not found: $client_name"
                continue
            fi

            client_pri_key=$(cat $KEYS_DIR/${client_name}_private.key)
            server_pub_key=$(cat ${KEYS_DIR}/server_public.key)
            echo "Generating config for $client_name"

            # backup current config if exists
            if [ -f "$KEYS_DIR/${client_name}.conf" ]; then
                mv "$KEYS_DIR/${client_name}.conf" "$KEYS_DIR/${client_name}.conf_$(date +%s)"
            fi

            cat >"$KEYS_DIR/${client_name}.conf" <<EOF
[Interface]
PrivateKey = $client_pri_key
Address = $TUNNEL_ADDR_PREFIX.${i}/24
DNS = 1.1.1.1, 8.8.8.8
[Peer]
PublicKey = ${server_pub_key}
Endpoint = ${SERVER_IP}:${SERVER_PORT}
AllowedIPs = $ROUTES
PersistentKeepalive = 21
EOF
        done
    }

    function main() {
        if [ ! -f /usr/bin/wg ]; then
            echo "Wireguard not found. Start Installing"
            install
        fi

        echo "Wireguard found! Generating config"
        gen_keys
        gen_server_config
        gen_client_config

        echo "Keys Generated, copy client config *.conf on /etc/wireguard/keys/ and import to wireguard client to start using"

        # stop service if running
        wg-quick down wg0

        # start service
        wg-quick up wg0
    }

    update_endpoint() {
        local IFACE=$1
        local ENDPOINT=$(cat /etc/wireguard/${IFACE}.conf | grep '^Endpoint' | cut -d '=' -f 2)
        # No need to refresh if ne endpoint.
        [ -z ${ENDPOINT} ] && return 0
        local HOSTNAME=$(echo ${ENDPOINT} | cut -d : -f 1)
        local PORT=$(echo ${ENDPOINT} | cut -d : -f 2)
        local PUBLIC_KEY="$(wg show ${IFACE} peers)"
        # No need to refresh if no handshake
        [ -z $(wg show ${IFACE} latest-handshakes | grep ${PUBLIC_KEY} | awk '{print $2}') ] && return 0
        local ADDRESS=$(host -4 ${HOSTNAME} | grep 'has address' | awk '{print $4}')
        # Return if we don't find any matching lines here - that means our IP address matches.
        [ -z "$(wg show ${IFACE} endpoints | grep ${PUBLIC_KEY} | grep ${ADDRESS})" ] || return 0
        wg set ${IFACE} peer ${PUBLIC_KEY} endpoint "${HOSTNAME}:${PORT}"
    }

    WG_IFS=$(wg show interfaces)

    for WG_IF in $WG_IFS; do
        update_endpoint $WG_IF
    done

}
