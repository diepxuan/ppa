#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("host:name")
--host:name() { # FQDN dc
    hostname -s
}

_DUCTN_COMMANDS+=("host:domain")
host_domain=$(hostname -d)
--host:domain() { # FQDN diepxuan.com
    [[ -z $host_domain ]] && host_domain=diepxuan.com
    echo $host_domain
}

_DUCTN_COMMANDS+=("host:fullname")
host_fullname=
--host:fullname() { # FQDN dc.diepxuan.com
    [[ -z $host_fullname ]] && host_fullname="$(--host:name).$(--host:domain)"
    echo $host_fullname
}

_DUCTN_COMMANDS+=("host:address")
--host:address() {
    if [[ -n "$*" ]]; then
        --host:address:valid $(host $@ | grep -wv -e alias | cut -f4 -d' ')
    else
        --host:address $(--host:fullname)
    fi
}

--host:address:valid() {
    --ip:valid "$@"
}

#_DUCTN_COMMANDS+=("host:ip")
--host:ip() {
    --host:address "$@"
}

--host:is_server() {
    [[ -n $* ]] && host_name=$1 || host_name=$(--host:fullname)
    [[ $host_name =~ ^pve[0-9].diepxuan.com$ ]] && echo 1 || echo 0
    unset host_name
}

--host:is_vpn_server() {
    [[ -n $* ]] && host_name=$1 || host_name=$(--host:fullname)
    [[ $host_name =~ ^pve[0-9].vpn$ ]] && echo 1 || echo 0
    unset host_name
}

_DUCTN_COMMANDS+=("host:serial")
host_serial=
--host:serial() {
    [[ -z $host_serial ]] && host_serial=$(--host:name) && host_serial=${host_serial:3}
    [[ -z $host_serial ]] && host_serial=1
    echo $host_serial
}

# copy from https://gist.github.com/irazasyed/a7b0a079e7727a4315b9

_DUCTN_COMMANDS+=("hosts:remove")
--hosts:remove() {
    --sys:hosts:remove $1 $2
}

_DUCTN_COMMANDS+=("hosts:add")
--hosts:add() {
    --sys:hosts:add $1 $2
}

_DUCTN_COMMANDS+=("hosts")
--hosts() {
    "--hosts:$*"
}

ETC_HOSTS=/etc/hosts

# sed -i 's/var=.*/var=new_value/' file_name

_DUCTN_COMMANDS+=("sys:hosts:add")
--sys:hosts:add() {
    IP=$1
    HOSTNAME=$2

    HOSTS_LINE="$IP\t$HOSTNAME"

    if [[ ! -n $(grep -P "${IP}[[:space:]]${HOSTNAME}" $ETC_HOSTS) ]]; then
        echo -e $HOSTS_LINE | sudo tee -a /etc/hosts >/dev/null
    fi

    # [[ -n $(grep -P "$IP[[:space:]]$HOSTNAME" $ETC_HOSTS) ]] && echo ">> Hosts added: $(grep $HOSTNAME $ETC_HOSTS)" || echo "Failed to Add $HOSTNAME, Try again!"
}

_DUCTN_COMMANDS+=("sys:hosts:remove")
--sys:hosts:remove() {
    IP=$1
    HOSTNAME=$2

    sudo sed -i "/$HOSTNAME/d" $ETC_HOSTS
    # grep -P "pve2.vpn" | sudo tee $ETC_HOSTS

    # [[ -n "$(grep $HOSTNAME /etc/hosts)" ]] && echo ">> Hosts removed: $HOSTNAME" || echo "$HOSTNAME was not found!"
}

_DUCTN_COMMANDS+=("sys:hosts:domain")
--sys:hosts:domain() {
    IP=$(--ip:wan)
    HOSTNAME="$(--host:fullname) $(--host:name)"
    HOSTS_LINE="$IP\\t$HOSTNAME"
    echo -e $HOSTS_LINE
}

_DUCTN_COMMANDS+=("sys:hosts:update")
--sys:hosts:update() {
    sed -i 's/var=.*/var=new_value/' ${ETC_HOSTS}
}
