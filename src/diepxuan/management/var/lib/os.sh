#!/usr/bin/env bash
#!/bin/bash

d_os:CODENAME() {
    [[ "$1" == "--help" ]] &&
        echo "Get OS codename" &&
        return
    [[ "$OSTYPE" == "darwin"* ]] &&
        CODENAME=$(sw_vers -productVersion | awk -F '.' '{print $1"."$2}')
    [[ -f /etc/os-release ]] && . /etc/os-release
    [[ -f /etc/lsb-release ]] && . /etc/lsb-release
    CODENAME=${CODENAME:-$DISTRIB_CODENAME}
    CODENAME=${CODENAME:-$VERSION_CODENAME}
    CODENAME=${CODENAME:-$UBUNTU_CODENAME}
    CODENAME=${CODENAME:-"unknown"}

    echo "$CODENAME"
}

d_os:RELEASE() {
    [[ "$1" == "--help" ]] &&
        echo "Get OS RELEASE" &&
        return
    [[ "$OSTYPE" == "darwin"* ]] &&
        RELEASE=$(sw_vers -buildVersion)
    RELEASE=${RELEASE:-$(echo $DISTRIB_DESCRIPTION | awk '{print $2}')}
    RELEASE=${RELEASE:-$(echo $VERSION | awk '{print $1}')}
    RELEASE=${RELEASE:-$(echo $PRETTY_NAME | awk '{print $2}')}
    RELEASE=${RELEASE:-${DISTRIB_RELEASE}}
    RELEASE=${RELEASE:-${VERSION_ID}}
    # RELEASE=$(echo "$RELEASE" | awk -F. '{print $1"."$2}')
    RELEASE=$(echo "$RELEASE" | cut -d. -f1-2)
    RELEASE=$(echo "$RELEASE" | tr '[:upper:]' '[:lower:]')
    RELEASE=${RELEASE//[[:space:]]/}
    RELEASE=${RELEASE%.}

    echo "$RELEASE"
}

d_os:DISTRIB() {
    [[ "$1" == "--help" ]] &&
        echo "Get OS DISTRIB" &&
        return
    [[ "$OSTYPE" == "darwin"* ]] &&
        DISTRIB=$(sw_vers -ProductName)
    DISTRIB=${DISTRIB:-$DISTRIB_ID}
    DISTRIB=${DISTRIB:-$ID}
    DISTRIB=$(echo "$DISTRIB" | tr '[:upper:]' '[:lower:]')

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
