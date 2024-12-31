#!/usr/bin/env bash
#!/bin/bash

SUDO="sudo"
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
fi

_DUCTN_COMMANDS+=("sys:init")
--sys:init() {
    sudo timedatectl set-timezone Asia/Ho_Chi_Minh

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

_DUCTN_COMMANDS+=("sys:sysctl")
--sys:sysctl() {
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

_DUCTN_COMMANDS+=("selfupdate")
--selfupdate() {
    --sys:upgrade
    ductn sys:init
}

_DUCTN_COMMANDS+=("sys:upgrade")
--sys:upgrade() {
    sudo apt update
    sudo apt install --only-upgrade ductn -y --purge --auto-remove
    # ductn sys:init
    # ductn sys:clean
    # ductn sys:service:re-install
}
