#!/usr/bin/env bash
#!/bin/bash

d_alias:ll() {
    [[ "$1" == "--help" ]] &&
        echo "Alias script ll. Displays directory contents in long format (like ls -la)." &&
        return

    # Kiểm tra xem alias ll có tồn tại không
    if alias ll >/dev/null 2>&1; then
        # Nếu có alias, sử dụng alias
        # command ll "$@"
        eval "ll $@"
    else
        # Nếu không có alias, sử dụng lệnh ls -lah
        ls -lah "$@"
    fi
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
