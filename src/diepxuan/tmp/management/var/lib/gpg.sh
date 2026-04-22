#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("gpg")
--gpg() {
    gpg --list-secret-keys --keyid-format LONG
}

_DUCTN_COMMANDS+=("gpg:export")
--gpg:export() {
    user=$(whoami)
    pwd=$(eval echo "~$user")
    [[ -n "$*" ]] && pwd=$1

    gpg --export --export-options backup --output "$pwd/public.gpg"
    gpg --export-secret-keys --export-options backup --output "$pwd/private.gpg"
    gpg --export-ownertrust >"$pwd/trust.gpg"
}

_DUCTN_COMMANDS+=("gpg:import")
--gpg:import() {
    user=$(whoami)
    pwd=$(eval echo "~$user")
    [[ -n "$*" ]] && pwd=$1

    gpg --import "$pwd/public.gpg"
    gpg --import "$pwd/private.gpg"
    gpg --import-ownertrust "$pwd/trust.gpg"
}
