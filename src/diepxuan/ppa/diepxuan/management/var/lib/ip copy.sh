#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ip:wan")
_IP_EXTEND=
--ip:wan() {

    # IPANY="$(dig @ns1.google.com -t txt o-o.myaddr.l.google.com +short | tr -d \")"
    # GOOGv4="$(dig -4 @ns1.google.com -t txt o-o.myaddr.l.google.com +short | tr -d \")"
    # GOOGv6="$(dig -6 @ns1.google.com -t txt o-o.myaddr.l.google.com +short | tr -d \")"
    # AKAMv4="$(dig -4 @ns1-1.akamaitech.net -t a whoami.akamai.net +short)"
    # CSCOv4="$(dig -4 @resolver1.opendns.com -t a myip.opendns.com +short)"
    # CSCOv6="$(dig -6 @resolver1.opendns.com -t aaaa myip.opendns.com +short)"
    # printf '$GOOG:\t%s\t%s\t%s\n' "${IPANY}" "${GOOGv4}" "${GOOGv6}"
    # printf '$AKAM:\t%s\n$CSCO:\t%s\t%s\n' "${AKAMv4}" "${CSCOv4}" "${CSCOv6}"

    # if [[ -z ${_IP_EXTEND+x} ]]; then continue; else
    #     # _IP_EXTEND=$(dig @resolver4.opendns.com myip.opendns.com +short)
    #     _IP_EXTEND=$(dig -4 @ns1.google.com -t txt o-o.myaddr.l.google.com +short | tr -d \")
    # fi

    [[ -z "$_IP_EXTEND" ]] && _IP_EXTEND="$(dig -4 @ns1.google.com -t txt o-o.myaddr.l.google.com +short 2>&1 | tr -d \" 2>/dev/null)"

    _IP_EXTEND=$(--ip:valid $_IP_EXTEND)
    echo "$_IP_EXTEND"
}

--ip:wanv4() {
    dig @resolver4.opendns.com myip.opendns.com +short -4
}

--ip:wanv6() {
    dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6
}

_DUCTN_COMMANDS+=("ip:local")
ip_local=
--ip:local() {
    [[ -z $ip_local ]] && ip_local=$(hostname -I | awk '{print $1}')
    echo $ip_local
}

--ip:localAll() {
    hostname -I
}

--ip:gateway() {
    ip r | grep ^default | head -n 1 | grep -oP '(?<=via )[^ ]*'
}

--ip:valid() {
    _IP=$@
    if expr "$_IP" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
        echo $_IP
    else
        echo $(--ip:local)
    fi
}

--ip:subnet() {
    # ip -4 a show $(--route:default) | awk '/inet/ {print $2}'
    ip r | grep vmbr1 | awk '{print $1}'
}

--ip:netmask_old() {
    c=0 x=0$(printf '%o' ${1//./ })
    while [ $x -gt 0 ]; do
        let c+=$((x % 2)) 'x>>=1'
    done
    echo /$c
}

# _DUCTN_COMMANDS+=("ip:check")
--ip:check() {
    # Specify DNS server
    dnsserver="8.8.8.8"
    # function to get IP address
    function get_ipaddr {
        ip_address=""
        # A and AAA record for IPv4 and IPv6, respectively
        # $1 stands for first argument
        if [ -n "$1" ]; then
            hostname="${1}"
            if [ -z "query_type" ]; then
                query_type="A"
            fi
            # use host command for DNS lookup operations
            host -t ${query_type} ${hostname} ${dnsserver} &>/dev/null
            if [[ "$?" -eq "0" ]]; then
                # get ip address
                ip_address="$(host -t ${query_type} ${hostname} ${dnsserver} | awk '/has.*address/{print $NF; exit}')"
            else
                exit 1
            fi
        else
            exit 2
        fi
        # display ip
        echo $ip_address
    }
    hostname="$(--host:fullname)"
    for query in "A-IPv4" "AAAA-IPv6"; do
        query_type="$(printf $query | cut -d- -f 1)"
        ipversion="$(printf $query | cut -d- -f 2)"
        address="$(get_ipaddr ${hostname})"
        if [ "$?" -eq "0" ]; then
            if [ -n "${address}" ]; then
                echo "The ${ipversion} adress of the Hostname ${hostname} is: $address"
            fi
        else
            echo "An error occurred"
        fi
    done
}
