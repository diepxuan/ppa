#!/usr/bin/env bash
#!/bin/bash

d_log() {
    [[ "$1" == "--help" ]] &&
        echo "Show system log" &&
        return
    d_log:watch "$@"
}

d_log:watch() {
    [[ "$1" == "--help" ]] &&
        echo "Watch service log" &&
        return
    local service=$*
    [[ -z $service ]] && --log:watch
    [[ -n $service ]] && --log:watch:service ${service//.service/}
}

--log:watch() {
    _log=/var/log/*log
    [[ -f /var/opt/mssql/log/errorlog ]] && _log="$_log /var/opt/mssql/log/errorlog"
    $SUDO tail -f $_log
}

--log:watch:service() {
    $SUDO journalctl -u "$@".service -f
}

--log:cleanup() {

    # #!/bin/sh
    # if [ -d "/var/opt/mssql/log" ]; then
    #     sudo find /var/opt/mssql/log -type f -regex ".*\.gz$" -delete
    #     sudo find /var/opt/mssql/log -type f -regex ".*\.[0-9]$" -delete
    #     logs=$(sudo find /var/opt/mssql/log -type f)
    #     for i in $logs; do
    #         sudo truncate -s 0 $i
    #     done
    # fi

    #!/bin/sh

    # Check the Drive Space Used by Cached Files
    # du -sh /var/cache/apt/archives

    # Clean all the log file
    # for logs in `find /var/log -type f`;  do > $logs; done

    logs=$($SUDO find /var/log -type f)
    for i in $logs; do
        $SUDO truncate -s 0 $i
    done

    #Getting rid of partial packages
    # sudo apt-get clean && sudo apt-get autoclean
    # apt-get remove --purge -y software-properties-common

    #Getting rid of no longer required packages
    # sudo apt-get autoremove -y

    #Getting rid of orphaned packages
    # deborphan | xargs sudo apt-get -y remove --purge

    #Free up space by clean out the cached packages
    # apt-get clean

    # Remove the Trash
    $SUDO rm -rf /home/*/.local/share/Trash/*/**
    $SUDO rm -rf /root/.local/share/Trash/*/**

    # Remove Man
    $SUDO rm -rf /usr/share/man/??
    $SUDO rm -rf /usr/share/man/??_*

    #Delete all .gz and rotated file
    # $SUDO find /var/log -type f -regex ".*\.gz$" | xargs $SUDO rm -Rf
    # $SUDO find /var/log -type f -regex ".*\.[0-9]$" | xargs $SUDO rm -Rf
    $SUDO find /var/log /var/opt/mssql/log -type f -regex ".*\.gz$" -delete
    $SUDO find /var/log /var/opt/mssql/log -type f -regex ".*\.[0-9]*$" -delete

    #Cleaning the old kernels
    # dpkg-query -l|grep linux-im*
    #dpkg-query -l |grep linux-im*|awk '{print $2}'
    # apt-get purge $(dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | head -n -1) --assume-yes
    # apt-get install linux-headers-`uname -r|cut -d'-' -f3`-`uname -r|cut -d'-' -f4`
}

--log:config() {
    $SUDO truncate -s 0 /etc/logrotate.d/ductn
    --log:config:store
    --log:config:mssql

    $SUDO logrotate -f /etc/logrotate.d/ductn
}

--log:config:store() {
    if id "store" &>/dev/null; then
        echo "/home/store/public_html/var/log/*.log {
    su store www-data
    size 1M
    copytruncate
    rotate 1
}
" | $SUDO tee --append /etc/logrotate.d/ductn >/dev/null
    fi
}

--log:config:mssql() {
    if id "mssql" &>/dev/null; then
        echo "/var/opt/mssql/log/errorlog /var/opt/mssql/log/*.log {
    su mssql mssql
    size 10M
    copytruncate
    missingok
    rotate 1
}
" | $SUDO tee --append /etc/logrotate.d/ductn >/dev/null
    fi

}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
