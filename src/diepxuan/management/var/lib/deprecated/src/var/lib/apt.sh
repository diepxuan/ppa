#!/usr/bin/env bash
#!/bin/bash

d_sys:apt:fix() {
    d_apt:fix $@
}

d_sys:apt:check() {
    [[ "$1" == "--help" ]] &&
        echo "Apt check if package is installed" &&
        return

    dpkg -s $1 2>/dev/null | grep 'install ok installed' >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo 0
    else
        echo 1
    fi

    # REQUIRED_PKG=$1
    # PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
    # # echo Checking for $REQUIRED_PKG: $PKG_OK
    # if [ "" = "$PKG_OK" ]; then
    #     #     echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
    #     #     sudo apt-get --yes install $REQUIRED_PKG
    #     echo 0
    # else
    #     echo 1
    # fi

}

--sys:apt:install() {
    if [[ "$(d_sys:apt:check $*)" -eq 0 ]]; then
        $SUDO apt install $* -y --purge --auto-remove
    fi
}

--sys:apt:remove() {
    $SUDO apt remove $* -y --purge --auto-remove
}

--sys:apt:uninstall() {
    --sys:apt:remove $*
}

d_apt:fix() {
    [[ "$1" == "--help" ]] &&
        echo "Apt fix lock files" &&
        return

    $SUDO killall apt-get
    $SUDO killall apt

    $SUDO rm /var/lib/apt/lists/lock
    $SUDO rm /var/cache/apt/archives/lock
    $SUDO rm /var/lib/dpkg/lock
    $SUDO rm /var/lib/dpkg/lock-frontend

    $SUDO dpkg --configure -a
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
