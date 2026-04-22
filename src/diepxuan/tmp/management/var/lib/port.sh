#!/usr/bin/env bash
#!/bin/bash

d_port:open() {
    [[ "$1" == "--help" ]] &&
        echo "Display Open Ports in Listening State" &&
        return
    $SUDO lsof -nP | grep LISTEN
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
