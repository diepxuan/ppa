#!/usr/bin/env bash
#!/bin/bash

CERTDIR=/etc/mysql/certs/
# _MYSQLDIR="/var/www/base/lib/mysql"

_DUCTN_COMMANDS+=("mysql:setup")
--mysql:setup() {
    --swap:install
    sudo apt install -y --purge --auto-remove mysql-server
    # sudo mysql_secure_installation
}

_DUCTN_COMMANDS+=("mysql:ssl:enable")
--mysql:ssl:enable() {
    # mkdir $CERTDIR
    # openssl genrsa 4096 | sudo tee ca-key.pem
    # sudo cp $_MYSQLDIR/ssl/*.pem $CERTDIR

    sudo openssl req -new -x509 -nodes -days 365000 -key $CERTDIR/ca-key.pem -out $CERTDIR/ca-cert.pem

    sudo openssl req -newkey rsa:2048 -days 365000 -nodes -keyout $CERTDIR/server-key.pem -out $CERTDIR/server-req.pem
    sudo openssl rsa -in $CERTDIR/server-key.pem -out $CERTDIR/server-key.pem
    sudo openssl x509 -req -in $CERTDIR/server-req.pem -days 365000 -CA $CERTDIR/ca-cert.pem -CAkey $CERTDIR/ca-key.pem -set_serial 01 -out $CERTDIR/server-cert.pem

    sudo openssl req -newkey rsa:2048 -days 365000 -nodes -keyout $CERTDIR/client-key.pem -out $CERTDIR/client-req.pem
    sudo openssl rsa -in $CERTDIR/client-key.pem -out $CERTDIR/client-key.pem
    sudo openssl x509 -req -in $CERTDIR/client-req.pem -days 365000 -CA $CERTDIR/ca-cert.pem -CAkey $CERTDIR/ca-key.pem -set_serial 01 -out $CERTDIR/client-cert.pem

    openssl verify -CAfile $CERTDIR/ca-cert.pem $CERTDIR/server-cert.pem $CERTDIR/client-cert.pem

    # cat $_MYSQLDIR/ssl/10-ssl.cnf | sudo tee /etc/mysql/conf.d/10-ssl.cnf
    # sudo chown -R mysql:root $CERTDIR
}
