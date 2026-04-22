#!/usr/bin/env bash
#!/bin/bash

d_os:CODENAME() {
    [[ "$1" == "--help" ]] &&
        echo "Get OS codename" &&
        return
    CODENAME=$(sw_vers -productVersion | awk -F '.' '{print $1"."$2}')
    echo "$CODENAME"
}

d_os:RELEASE() {
    [[ "$1" == "--help" ]] &&
        echo "Get OS RELEASE" &&
        return
    RELEASE=$(sw_vers -buildVersion)
    echo "$RELEASE"
}

d_os:DISTRIB() {
    [[ "$1" == "--help" ]] &&
        echo "Get OS DISTRIB" &&
        return
    DISTRIB=$(sw_vers -ProductName)
    echo "$DISTRIB"
}

d_os:TYPE() {
    uname -s
}

d_os:list() {
    [[ "$1" == "--help" ]] &&
        echo "List linux releases" &&
        return
    # URL to fetch the Ubuntu releases list
    UBUNTU_RELEASES_URL="https://releases.ubuntu.com/"

    # Fetch the list of Ubuntu releases and extract version and code name
    curl -s $UBUNTU_RELEASES_URL | grep -Eo '[0-9]{2}\.[0-9]{2} LTS|Ubuntu [^<]+' | sed 's/Ubuntu //' | while read -r line; do
        # Extract version and code name
        if [[ $line =~ ([0-9]{2}\.[0-9]{2}) ]]; then
            version=${BASH_REMATCH[1]}
        else
            codename=$line
            echo "$version - $codename"
        fi
    done
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
