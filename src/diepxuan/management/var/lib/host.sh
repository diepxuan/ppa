#!/usr/bin/env bash
#!/bin/bash

d_host:name() { # FQDN dc
    hostname -s
}

d_host:domain() { # FQDN diepxuan.com
    host_domain=$(hostname -d)
    [[ -z $host_domain ]] && host_domain=diepxuan.corp
    echo $host_domain
}

d_host:fullname() { # FQDN dc.diepxuan.com
    host_fullname=$(hostname -f)
    [[ -z $host_fullname ]] && host_fullname="$(d_host:name).$(d_host:domain)"
    echo $host_fullname
}

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

host_serial=
--host:serial() {
    [[ -z $host_serial ]] && host_serial=$(--host:name) && host_serial=${host_serial:3}
    [[ -z $host_serial ]] && host_serial=1
    echo $host_serial
}

--hosts:remove() {
    --sys:hosts:remove $1 $2
}

--hosts:add() {
    --sys:hosts:add $1 $2
}

--hosts() {
    "--hosts:$*"
}

ETC_HOSTS=/etc/hosts

--sys:hosts:add() {
    IP=$1
    HOSTNAME=$2

    HOSTS_LINE="$IP\t$HOSTNAME"

    if [[ ! -n $(grep -P "${IP}[[:space:]]${HOSTNAME}" $ETC_HOSTS) ]]; then
        echo -e $HOSTS_LINE | sudo tee -a /etc/hosts >/dev/null
    fi
}

--sys:hosts:remove() {
    IP=$1
    HOSTNAME=$2

    sudo sed -i "/$HOSTNAME/d" $ETC_HOSTS
}

--sys:hosts:domain() {
    IP=$(--ip:wan)
    HOSTNAME="$(--host:fullname) $(--host:name)"
    HOSTS_LINE="$IP\\t$HOSTNAME"
    echo -e $HOSTS_LINE
}

--sys:hosts:update() {
    sed -i 's/var=.*/var=new_value/' ${ETC_HOSTS}
}

# d_host() {
#     [[ $(type -t _dev:host:$1) == function ]] && "_dev:host:$@" && exit 0
#     [[ $(type -t --host:$1) == function ]] && "--host:$@" && exit 0
# }

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
