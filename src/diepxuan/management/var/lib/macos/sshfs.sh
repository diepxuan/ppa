#!/usr/bin/env bash
#!/bin/bash

d_sshfs:install() {
    [[ "$1" == "--help" ]] &&
        echo "Install SSHFS" &&
        return
    if [[ ! -x "$(command -v sshfs)" ]]; then
        brew install gromgit/fuse/sshfs-mac
    fi
}

d_sshfs:service:restart() {
    [[ "$1" == "--help" ]] &&
        echo "Restart SSHFS service" &&
        return
    d_sshfs:service:stop
    d_sshfs:service:start
}

d_sshfs:service:install() {
    [[ "$1" == "--help" ]] &&
        echo "Install SSHFS service" &&
        return
    echo "$SSHFS_SERVICE" | $SUDO tee /Library/LaunchDaemons/com.user.sshfs.plist >/dev/null
    d_sshfs:install
    d_sshfs:service:restart
}

d_sshfs:service:start() {
    [[ "$1" == "--help" ]] &&
        echo "Start SSHFS service" &&
        return

    $SUDO launchctl bootstrap system /Library/LaunchDaemons/com.user.sshfs.plist # 10.13+
    $SUDO launchctl enable system/com.user.sshfs
}

d_sshfs:service:stop() {
    [[ "$1" == "--help" ]] &&
        echo "Stop SSHFS service" &&
        return
    $SUDO launchctl bootout system /Library/LaunchDaemons/com.user.sshfs.plist
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi

SSHFS_SERVICE=$(
    cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.sshfs</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/sshfs</string>
        <string>-o</string>
        <string>auto_cache,reconnect,allow_other,IdentityFile=/Users/ductn/.ssh/id_rsa</string>
        <string>root@web.diepxuan.corp:/var/www/laravel</string>
        <string>/Users/ductn/Developer/laravel</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Library/Logs/com.user.sshfs.out.log</string>
    <key>StandardErrorPath</key>
    <string>/Library/Logs/com.user.sshfs.err.log</string>
</dict>
</plist>
EOF
)
