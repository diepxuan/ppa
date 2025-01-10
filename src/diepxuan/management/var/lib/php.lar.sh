#!/usr/bin/env bash
#!/bin/bash

_laravel() {
    [[ ! -f artisan ]] && exit 0
    php artisan $*
}

d_php:lar() {
    [[ "$1" == "--help" ]] &&
        echo "Laravel extend command" &&
        return
    _laravel $@
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
