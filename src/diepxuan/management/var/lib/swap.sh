#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("swap:remove")
--swap:remove() {
    sudo swapoff -v /swapfile
    sudo rm /swapfile
}

_DUCTN_COMMANDS+=("swap:install")
--swap:install() {
    --swap:remove
    sudo rm -rf /swapfile
    sudo fallocate -l 2G /swapfile
    #sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
}

# free -m
