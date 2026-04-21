#!/usr/bin/env bash
#!/bin/bash

--do_no_thing() {
    return 0
}

--logger() {
    logger "$*"
}

--echo() {
    echo -e "\r$@" 2>/dev/null
}

version=
--version() {
    [[ -z $version ]] && version=$(dpkg -s ductn | grep Version) && version=${version//'Version: '/}
    echo $version
}

---v() {
    --version
}

--ssh() {
    ssh -T $1 "$2" 2>/dev/null
}

_DUCTN_COMMANDS+=("hash_MD5")
--hash_MD5() {
    echo $RANDOM | md5sum | head -c 20
}
