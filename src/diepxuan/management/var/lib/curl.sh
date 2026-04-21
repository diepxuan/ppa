#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("curl:get")
--curl:get() {
    url=$*
    {
        IFS= read -rd '' out
        IFS= read -rd '' http_code
        IFS= read -rd '' status
    } < <(
        { out=$(curl -sSL -o /dev/stderr -w "%{http_code}" $url); } 2>&1
        printf '\0%s' "$out" "$?"
    )

    # echo out $out
    # echo http_code $http_code
    # echo status $status

    [[ $status == 0 ]] && [[ $http_code == 200 ]] && echo "$out" 2>&1

}

--curl:gg() {
    FILEID=$1
    FILENAME=$2
    comfirm=$(
        wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$FILEID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p'
    )
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$comfirm  &id=$FILEID" -O $FILENAME
    rm -rf /tmp/cookies.txt
}
