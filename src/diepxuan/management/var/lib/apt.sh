#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:apt:fix")
--sys:apt:fix() {
    --apt:fix
}

_DUCTN_COMMANDS+=("sys:apt:check")
--sys:apt:check() {
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

_DUCTN_COMMANDS+=("sys:apt:install")
--sys:apt:install() {
    if [[ "$(--sys:apt:check $*)" -eq 0 ]]; then
        sudo apt install $* -y --purge --auto-remove
    fi
}

_DUCTN_COMMANDS+=("sys:apt:remove")
--sys:apt:remove() {
    sudo apt remove $* -y --purge --auto-remove
}

_DUCTN_COMMANDS+=("sys:apt:uninstall")
--sys:apt:uninstall() {
    --sys:apt:remove $*
}

--apt:fix() {
    #!/bin/bash

    sudo killall apt-get
    sudo killall apt

    sudo rm /var/lib/apt/lists/lock
    sudo rm /var/cache/apt/archives/lock
    sudo rm /var/lib/dpkg/lock
    sudo rm /var/lib/dpkg/lock-frontend

    sudo dpkg --configure -a
}
