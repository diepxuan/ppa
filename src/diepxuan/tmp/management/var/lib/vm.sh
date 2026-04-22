#!/usr/bin/env bash
#!/bin/bash

d_vm:info() {
    [[ "$1" == "--help" ]] &&
        echo "Display VM Information" &&
        return
    cat <<EOF
VM Information:
    Hostname:   $(d_host:fullname)
    IP Address: $(d_ip:local)
    DISTRIB:    $(d_os:DISTRIB)
    OS:         $(d_os:CODENAME)
    RELEASE:    $(d_os:RELEASE)
EOF
}

--pve:vm() {
    --sys:apt:install qemu-guest-agent
}

# CSRF_TOKEN=

d_vm:sync() {
    [[ "$1" == "--help" ]] &&
        echo "Sync VM Information" &&
        return
    d_vm_sync_doing=true
    _vm:sync:ip_address $@
    d_vm_sync_doing=false
}

_vm:sync:ip_address() {
    _tolen=3ccbb8eb47507c42a3dfd2a70fe8e617509f8a9e4af713164e0088c715d24c83
    _api=https://dns.diepxuan.corp:53443/api
    _domain=diepxuan.corp
    _hostName=$(d_host:name)
    # _fullName=$(d_host:fullname)
    _fullName=${1:-$(d_host:fullname)}
    _url_get="$_api/zones/records/get?token=$_tolen&domain=$_fullName&zone=$_domain&listZone=true"
    _url_add="$_api/zones/records/add?token=$_tolen&domain=$_fullName&zone=$_domain&type=A&ipAddress="
    _url_del="$_api/zones/records/delete?token=$_tolen&domain=$_fullName&zone=$_domain&type=A&ipAddress="

    response=$(curl -s -w "%{http_code}" -o >(cat) $_url_get)
    http_status=${response: -3}
    response_body="${response:0:${#response}-3}"
    status=$(echo $response_body | jq -r '.status')
    body=$(echo $response_body | jq -r '.response')

    # echo "HTTP Status Code: $http_status"
    # echo "Status: $status"
    # echo "Response Body: $body"
    [[ "$http_status" == "200" ]] && {
        [[ "$status" == "ok" ]] &&
            old_ips=$(echo $body | jq -r '.records[] | select(.type == "A") | .rData.ipAddress')
    }

    old_ips=${old_ips[*]:-}
    new_ips=${new_ips:-$(d_ip:local)}

    # echo "Old ips: $old_ips"
    # echo "New ips: $new_ips"

    # Loại bỏ các IP trong old_ips không có trong new_ips
    for old_ip in $old_ips; do
        if [[ ! $new_ips =~ $old_ip ]]; then
            # echo "Removing IP: $old_ip"
            response=$(curl -s -w "%{http_code}" -o >(cat) ${_url_del}${old_ip})
            http_status=${response: -3}
            if [[ $http_status == 200 ]]; then
                response_body="${response:0:${#response}-3}"
                status=$(echo $response_body | jq -r '.status' 2>/dev/null)
                body=$(echo $response_body | jq -r '.response' 2>/dev/null)
            # echo $response_body
            fi
        fi
    done

    # Thêm các IP trong new_ips không có trong old_ips
    for new_ip in $new_ips; do
        if [[ ! $old_ips =~ $new_ip ]]; then
            # echo "Adding IP: $new_ip"
            response=$(curl -s -w "%{http_code}" -o >(cat) ${_url_add}${new_ip})
            http_status=${response: -3}
            if [[ $http_status == 200 ]]; then
                response_body="${response:0:${#response}-3}"
                status=$(echo $response_body | jq -r '.status' 2>/dev/null)
                body=$(echo $response_body | jq -r '.response' 2>/dev/null)
                # echo $response_body
            fi
        fi
    done

}

_vm:command() {
    while read -r vm_cmd; do
        $vm_cmd
    done < <(echo $@ | jq -r '.vm.commands[]')
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
