#!/usr/bin/env bash
#!/bin/bash

####################################
#
# SSH
#
####################################
# Create PEM file
# ##############################
#
# openssl rsa -in id_rsa -outform PEM -out id_rsa.pem
# openssl x509 -outform der -in id_rsa.pem -out id_rsa.crt

# Change passphrase
# ##############################
# SYNOPSIS
# #ssh-keygen [-q] [-b bits] -t type [-N new_passphrase] [-C comment] [-f output_keyfile]
# #ssh-keygen -p [-P old_passphrase] [-N new_passphrase] [-f keyfile]
# #-f filename Specifies the filename of the key file.
# -N new_passphrase     Provides the new passphrase.
# -P passphrase         Provides the (old) passphrase.
# -p                    Requests changing the passphrase of a private key file instead of
#                       creating a new private key.  The program will prompt for the file
#                       containing the private key, for the old passphrase, and twice for
#                       the new passphrase.
#
# ssh-keygen -t rsa -y > ~/.ssh/id_rsa.pub
# ssh-keygen -f id_rsa -p

# Setup
# ##############################
_DUCTN_COMMANDS+=("ssh:install")
--ssh:install() {
    # ssh config
    # cat /var/www/base/ssh/config >~/.ssh/config
    # printf "\n\n" >>~/.ssh/config
    # find /var/www/base/ssh/config.d/*.conf -type f -exec cat {} \; -exec printf "\n\n" \; >>~/.ssh/config

    # ssh private key
    # cat /var/www/base/ssh/id_rsa >~/.ssh/id_rsa
    # cat /var/www/base/ssh/gss > ~/.ssh/gss
    # cat /var/www/base/ssh/tci > ~/.ssh/tci
    # cat /var/www/base/ssh/gem > ~/.ssh/gem

    # ssh public key
    ssh-keygen -f ~/.ssh/id_rsa -y >~/.ssh/id_rsa.pub
    # ssh-keygen -f ~/.ssh/gss -y > ~/.ssh/gss.pub
    # ssh-keygen -f ~/.ssh/tci -y > ~/.ssh/tci.pub
    # ssh-keygen -f ~/.ssh/gem -y > ~/.ssh/gem.pub
    --ssh:permision

    # ssh-copy-id user@123.45.56.78

    # cat /var/www/base/ssh/id_rsa        | ssh dx1.diepxuan.com "cat > ~/.ssh/id_rsa"
    # cat /var/www/base/ssh/id_rsa.pub    | ssh dx1.diepxuan.com "cat > ~/.ssh/id_rsa.pub"
    # ssh dx1.diepxuan.com "chmod 600 ~/.ssh/*"
}

--ssh:permision() {
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/*
}

_DUCTN_COMMANDS+=("ssh:copy")
--ssh:copy() {
    cat /var/www/base/ssh/id_rsa | ssh ${1} "cat > ~/.ssh/id_rsa"
    ssh ${1} "chmod 600 ~/.ssh/*"
    ssh ${1} "ssh-keygen -f ~/.ssh/id_rsa -y >~/.ssh/id_rsa.pub"
    # cat /var/www/base/ssh/id_rsa.pub | ssh ${1} "cat > ~/.ssh/id_rsa.pub"
}
