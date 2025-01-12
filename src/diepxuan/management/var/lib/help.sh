#!/usr/bin/env bash
#!/bin/bash

d_-v() {
    echo -e ductn version $Green$(d_version)$NC
    echo ''
    echo Su dung:
    echo "  command [options] [arguments]"
    echo ''

    declare -F |
        awk '{print $3}' |
        grep -e "^$_GLOBAL_EXEC" |
        sed "s/$_GLOBAL_EXEC//g" |
        grep -Ev 'commands|-v|version:newrelease' |
        while read cmd; do
            # Kiểm tra nếu command không hỗ trợ tham số --help
            # [[ !type "$cmd" 2>/dev/null ]] && continue
            # if ! type "$cmd" &>/dev/null || ! $cmd --help &>/dev/null; then
            #     continue
            # fi
            echo -e $Green$cmd$NC $("d_$cmd" --help)
            # echo -e $Green$cmd$NC d_$cmd d_$cmd
            # echo -e "$cmd $(d_$cmd --help)"
        done |
        awk '{ printf " %-35s %s \n", $1, substr($0, index($0,$2)) }'
    # declare -F | awk '{print $3}' | grep -e "^$_GLOBAL_EXEC" | sed "s/$_GLOBAL_EXEC//g" | grep -v "commands"
}

d_version() {
    [[ "$1" == "--help" ]] &&
        echo "Show package version" &&
        return
    version=$(apt show ductn 2>/dev/null | grep Version | awk '{print $2}')
    version=${version:-"$(dpkg-parsechangelog -S Version -l $_SRC_DIR/debian/changelog 2>/dev/null)"}
    version=${version:-"$(head -n 1 $_SRC_DIR/debian/changelog | awk -F '[()]' '{print $2}')"}
    version=${version:-"0.0.0"}
    echo $version
}

d_version:newrelease() {
    [[ "$1" == "--help" ]] &&
        echo "Get next release" &&
        return
    echo $(($(d_version | cut -d+ -f1 | tr -d '.') + 1)) | sed "s/\(.\)\(.\)\(.\)/\1.\2.\3/"
}

d_--version() {
    [[ "$1" == "--help" ]] &&
        echo "Alias for Version Command | Display Package Version" &&
        return
    d_version
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
