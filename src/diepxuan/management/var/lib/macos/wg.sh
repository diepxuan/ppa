#!/usr/bin/env bash
#!/bin/bash

d_wg:status() {
    [[ "$1" == "--help" ]] &&
        echo "Get WireGuard status" &&
        return
    if [[ -x "$(command -v wg)" ]]; then
        $SUDO wg show
    else
        echo "WireGuard is not installed."
    fi
}

d_wg:config() {
    [[ "$1" == "--help" ]] &&
        echo "Get WireGuard configuration" &&
        return
    if [[ -f /opt/homebrew/etc/wireguard/wg0.conf ]]; then
        $SUDO cat /opt/homebrew/etc/wireguard/wg0.conf
    else
        echo "WireGuard is not installed."
    fi
}

d_wg:install() {
    [[ "$1" == "--help" ]] &&
        echo "Install WireGuard tool" &&
        return
    if [[ -x "$(command -v brew)" ]]; then
        $SUDO brew install wireguard-tools
    else
        echo "Homebrew is not installed."
    fi
}

d_wg:service:restart() {
    [[ "$1" == "--help" ]] &&
        echo "Restart WireGuard service" &&
        return
    d_wg:service:stop
    d_wg:service:start
}

d_wg:service:start() {
    [[ "$1" == "--help" ]] &&
        echo "Start WireGuard service" &&
        return

    # sudo launchctl load -w /Library/LaunchDaemons/com.wireguard.wg0.plist
    # d_dns:set
    sudo launchctl bootstrap system /Library/LaunchDaemons/com.wireguard.wg0.plist # 10.13+
    sudo launchctl enable system/com.wireguard.wg0
    # d_dns:set 10.10.1.1 10.10.2.1 10.10.3.1 10.10.4.1
}
d_wg:service:stop() {
    [[ "$1" == "--help" ]] &&
        echo "Stop WireGuard service" &&
        return
    sudo launchctl bootout system /Library/LaunchDaemons/com.wireguard.wg0.plist
    d_dns:set
}

d_wg:service:install() {
    [[ "$1" == "--help" ]] &&
        echo "Install WireGuard service" &&
        return
    echo "$WGSERVICE" | $SUDO tee /Library/LaunchDaemons/com.wireguard.wg0.plist >/dev/null
    d_wg:install
    d_wg:hotfix
    d_wg:service:start
}

d_wg:hotfix() {
    [[ "$1" == "--help" ]] &&
        echo "Hotfix WireGuard service" &&
        return
    # Create a symlink to the wg-quick script in /opt/homebrew/bin
    # to ensure it uses the correct version of bash
    cat <<EOF | $SUDO tee /opt/homebrew/bin/wg-quick-bash5 >/dev/null
#!/opt/homebrew/bin/bash

source /opt/homebrew/bin/wg-quick
EOF
    $SUDO chmod +x /opt/homebrew/bin/wg-quick-bash5
}

nd_wg:fix() {
    #WG_QUICK_USERSPACE_INTERFACE="Wi-Fi"
    #export WG_QUICK_USERSPACE_INTERFACE="Wi-Fi"

    #WG_QUICK_DNS_SKIP=1
    #export WG_QUICK_DNS_SKIP=1

    services=$(networksetup -listallnetworkservices | tail -n +2)

    while IFS= read -r service; do
        clean_service=$(echo "$service" | sed 's/^\* //')
        trimmed=$(echo "$clean_service" | xargs)
        #underscored=$(echo "$trimmed" | tr ' ' '_')
        #sanitized=$(echo "$underscored" | sed 's/^_*\(.*\)_*$/\1/')
        sanitized=$(echo "$trimmed" | sed 's/^_*\(.*\)_*$/\1/')
        if [[ "$clean_service" != "$sanitized" ]]; then
            echo "'$clean_service' -> '$sanitized'"
            sudo networksetup -renamenetworkservice "$clean_service" "$sanitized"
        fi
    done <<<"$services"

}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi

WGSERVICE=$(
    cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.wireguard.wg0</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/wg-quick-bash5</string>
        <string>up</string>
        <string>wg0</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Library/Logs/com.wireguard.wg0.out.log</string>
    <key>StandardErrorPath</key>
    <string>/Library/Logs/com.wireguard.wg0.err.log</string>

    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
        <key>PathState</key>
        <dict>
            <key>/opt/homebrew/etc/wireguard/wg0.conf</key>
            <true/>
        </dict>
        <key>AfterInitialDemand</key>
        <true/>
    </dict>

    <key>WatchPaths</key>
    <array>
        <string>/opt/homebrew/etc/wireguard/wg0.conf</string>
    </array>

    <key>ThrottleInterval</key>
    <integer>5</integer>

    <key>StartInterval</key>
    <integer>60</integer>
</dict>
</plist>
EOF
)
