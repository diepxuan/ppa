#!/usr/bin/env bash
#!/bin/bash

_laravel() {
    [[ ! -f artisan ]] && exit 0
    php artisan $*
}

d_lar() {
    _laravel $@
}
