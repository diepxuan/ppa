#!/usr/bin/env bash
#!/bin/bash

USER_ID=${EUID:-$(id -u)}
SUDO=${SUDO:-'run_as_sudo'}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
