#!/usr/bin/env bash
#!/bin/bash

SUDO="sudo"
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
fi

--sys:init() {
    $SUDO timedatectl set-timezone Asia/Ho_Chi_Minh

    --user:config $USERNAME
    --git:configure

    --log:config
    --sys:sysctl >/dev/null

    --server() {
        --httpd:config
        --ssh:install
    }

    if [[ -n "$*" ]]; then
        "--$*"
    fi
}

d_sys:sysctl() {
    [[ "$1" == "--help" ]] &&
        echo "Update sysctl for ductn package" &&
        return
    _sysctl="fs.inotify.max_user_watches=524288
net.ipv4.ip_forward=1"

    while IFS= read -r rule; do
        sudo sysctl -w $rule
    done <<<"$_sysctl"

    echo "$_sysctl" | sudo tee /etc/sysctl.d/99-ductn.conf
    sudo sysctl -p
}

--sys:clean() {
    # remove bin
    sudo rm -rf /usr/local/bin/ductn

    # remove git configuration
    sudo rm -rf /var/www/base/.git/hooks/pre-commit
    sudo rm -rf /var/www/base/.git/hooks/push-to-checkout
    sudo rm -rf /var/www/base/.git/hooks/post-receive

    # remove bash configuration
    sed -i "/bash\/.bash_aliases/d" ~/.bash_aliases
}

--selfupdate() {
    --sys:upgrade
    ductn sys:init
}

--sys:upgrade() {
    sudo apt update
    sudo apt install --only-upgrade ductn -y --purge --auto-remove
    # ductn sys:init
    # ductn sys:clean
    # ductn sys:service:re-install
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
