#!/usr/bin/env bash
#!/bin/bash

--sys:ufw:disable() {
    sudo ufw disable 2>&1
    sudo systemctl stop ufw 2>&1

    --ufw:geoip:uninstall
    --ufw:fail2ban:uninstall
    --ufw:iptables:uninstall
}

--ufw:geoip:uninstall() {
    # sudo apt remove curl unzip perl -y --purge --auto-remove
    sudo apt remove xtables-addons-common -y --purge --auto-remove
    sudo apt remove libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl -y --purge --auto-remove
    sudo apt remove libnet-cidr-lite-perl -y --purge --auto-remove
}

--ufw:geoip:allowCloudflare() {
    # Allow Cloudflare IP
    # https://www.cloudflare.com/ips-v4
    # https://www.cloudflare.com/ips-v6
    # iptables -I INPUT -p tcp -m multiport --dports http,https -s $ip -j ACCEPT
    # -A ufw-before-input -p tcp -m multiport --dports http,https -s $ip -j ACCEPT

    v4ips="https://www.cloudflare.com/ips-v4"
    # echo "# v4: add to file /etc/ufw/before.rules"
    # echo "########################################"
    while IFS= read -r line; do
        echo -e "-A ufw-before-input -p tcp -m multiport --dports http,https -s ${line} -j ACCEPT\n"
    done < <(curl -s $v4ips)

    echo -e "\n\n"

    v6ips="https://www.cloudflare.com/ips-v6"
    # echo "# v6: add to file /etc/ufw/before6.rules"
    # echo "########################################"
    while IFS= read -r line; do
        # echo -e "-A ufw-before-input -p tcp -m multiport --dports http,https -s ${line} -j ACCEPT\n"
        echo ''
    done < <(curl -s $v6ips)
}

--ufw:fail2ban:uninstall() {
    --sys:apt:remove fail2ban -y --purge --auto-remove
}

--ufw:iptables:uninstall() {
    sudo systemctl stop ductn-iptables 2>/dev/null
    sudo systemctl disable ductn-iptables 2>/dev/null
    sudo rm -rf /usr/lib/systemd/system/ductn-iptables.service 2>/dev/null
    sudo systemctl daemon-reload 2>/dev/null
}
