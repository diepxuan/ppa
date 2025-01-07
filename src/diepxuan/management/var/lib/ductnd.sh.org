#!/usr/bin/env bash
#!/bin/bash

ETC_PATH=/etc/ductn
USER_BIN_PATH=~/bin
DIRTMP=/tmp/ductn
BASE_URL=https://admin.diepxuan.com

# check Dev mode
if [[ ! $BASH_SOURCE = /var/www/base/ductn ]] && [[ -f /var/www/base/ductn ]]; then
    source /var/www/base/ductn
    exit 0
fi

# load Dev libraries
if [[ $BASH_SOURCE = /var/www/base/ductn ]] && [[ -d /var/www/base/var/lib ]]; then
    for f in /var/www/base/var/lib/*.sh; do
        [[ -f $f ]] && source $f
    done
elif [ -d /var/lib/ductn ]; then # load Production libraries
    for f in /var/lib/ductn/*.sh; do
        [[ -f $f ]] && source $f
    done
fi

# create TMP dir
if [[ ! -d /tmp/ductn ]]; then
    mkdir -p /tmp/ductn
    sudo chmod 777 -R /tmp/ductn
fi

[[ ! "$(whoami)" -eq "ductn" ]] && exit 1

if [[ -n $* ]]; then
    "--$@"
fi

exit 0
