#!/usr/bin/env bash
#!/bin/bash

d_-v() {
    echo "ductn version $(d_version)"
    d_commands
}

d_version() {
    version=$(apt show ductn 2>/dev/null | grep Version | awk '{print $2}')
    version=${version:-"$(dpkg-parsechangelog -S Version -l $_SRC_DIR/debian/changelog 2>/dev/null)"}
    version=${version:-"$(head -n 1 $_SRC_DIR/debian/changelog | awk -F '[()]' '{print $2}')"}
    version=${version:-"0.0.0"}
    echo $version
}

d_version:newrelease() {
    echo $(($(d_version | tr -d '.') + 1)) | sed "s/\(.\)\(.\)\(.\)/\1.\2.\3/"
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
