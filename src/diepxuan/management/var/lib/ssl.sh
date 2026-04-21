#!/usr/bin/env bash
#!/bin/bash

# dns_cloudflare_email   = email@example.com
# dns_cloudflare_api_key = cloud_api
CLFR_ACCESS=/etc/ductn/cloudflare

_DUCTN_COMMANDS+=("ssl:install")
--ssl:install() {
    sudo apt install software-properties-common -y --purge --auto-remove
    # sudo add-apt-repository universe
    # sudo add-apt-repository ppa:certbot/certbot
    sudo apt update
    sudo apt install -y --purge --auto-remove python3-pip
    # sudo pip3 install certbot certbot-dns-cloudflare
    sudo apt install -y --purge --auto-remove certbot python3-certbot-dns-cloudflare
}

_DUCTN_COMMANDS+=("ssl:configure")
--ssl:configure() {
    [[ -f $CLFR_ACCESS ]] || return
    --ssl:setup
}

--ssl:setup() {
    #sudo certbot certonly --apache \
    #  --expand \
    #  --no-redirect \
    #  --keep-until-expiring \
    #  --break-my-certs \
    #  --pre-hook /var/www/base/bash/certbot/authenticator.sh \
    #  -m caothu91@gmail.com \
    #  --server https://acme-v02.api.letsencrypt.org/directory

    #_certbot solzatech.com,www.solzatech.com
    # _certbot diepxuan.com,www.diepxuan.com,luong.diepxuan.com,pma.diepxuan.com,cloud.diepxuan.com,work.diepxuan.com,shop.diepxuan.com
    --ssl:certbot diepxuan.com,*.diepxuan.com
    --ssl:certbot vps.diepxuan.com,*.vps.diepxuan.com

    sudo service apache2 restart

    #  sudo cat /etc/letsencrypt/live/mail.diepxuan.com/fullchain.pem | ssh server3.diepxuan.com "sudo tee /etc/letsencrypt/live/mail.diepxuan.com/fullchain.pem"
    #  sudo cat /etc/letsencrypt/live/mail.diepxuan.com/privkey.pem | ssh server3.diepxuan.com "sudo tee /etc/letsencrypt/live/mail.diepxuan.com/privkey.pem"

    # sudo scp -r /etc/letsencrypt/live/* dx3.diepxuan.com:/etc/letsencrypt/live/
}

--ssl:certbot() {

    [[ -f $CLFR_ACCESS ]] || return

    sudo chmod 600 $CLFR_ACCESS

    sudo certbot certonly \
        --expand \
        --keep-until-expiring \
        --dns-cloudflare \
        --dns-cloudflare-credentials $CLFR_ACCESS \
        --agree-tos \
        --email caothu91@gmail.com \
        --eff-email \
        -d $@
}

--ssl:pull() {
    sudo mkdir -p /etc/letsencrypt/live/diepxuan.com/
    ssh "$@" "sudo cat /etc/letsencrypt/live/diepxuan.com/cert.pem" | sudo tee /etc/letsencrypt/live/diepxuan.com/cert.pem
    ssh "$@" "sudo cat /etc/letsencrypt/live/diepxuan.com/chain.pem" | sudo tee /etc/letsencrypt/live/diepxuan.com/chain.pem
    ssh "$@" "sudo cat /etc/letsencrypt/live/diepxuan.com/fullchain.pem" | sudo tee /etc/letsencrypt/live/diepxuan.com/fullchain.pem
    ssh "$@" "sudo cat /etc/letsencrypt/live/diepxuan.com/privkey.pem" | sudo tee /etc/letsencrypt/live/diepxuan.com/privkey.pem
}

--ssl:push() {
    sudo cat /etc/letsencrypt/live/diepxuan.com/cert.pem | ssh "$@" "sudo tee /etc/letsencrypt/live/diepxuan.com/cert.pem"
    sudo cat /etc/letsencrypt/live/diepxuan.com/chain.pem | ssh "$@" "sudo tee /etc/letsencrypt/live/diepxuan.com/chain.pem"
    sudo cat /etc/letsencrypt/live/diepxuan.com/fullchain.pem | ssh "$@" "sudo tee /etc/letsencrypt/live/diepxuan.com/fullchain.pem"
    sudo cat /etc/letsencrypt/live/diepxuan.com/privkey.pem | ssh "$@" "sudo tee /etc/letsencrypt/live/diepxuan.com/privkey.pem"
}

--ssl:upload() {
    --push
}
