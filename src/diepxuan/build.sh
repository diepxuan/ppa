#!/usr/bin/env bash
#!/bin/bash

APT_CONF_FILE=/etc/apt/apt.conf.d/50build-deb-action

export DEBIAN_FRONTEND=noninteractive

cat | sudo tee "$APT_CONF_FILE" <<-EOF
APT::Get::Assume-Yes "yes";
APT::Install-Recommends "no";
Acquire::Languages "none";
quiet "yes";
EOF

ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
apt-get update
apt-get install -y dpkg-dev libdpkg-perl dput tree devscripts libdistro-info-perl software-properties-common debhelper-compat
apt-get install -y build-essential debhelper fakeroot gnupg reprepro wget curl git sudo vim locales
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

source_dir=${MODULE:-'management'}

apt-get build-dep -y -- "$source_dir"
cd $source_dir

ls -la
ls -la debian

echo "$GPG_KEY====" | tr -d '\n' | fold -w 4 | sed '$ d' | tr -d '\n' | fold -w 76 | base64 -di | gpg --batch --import || true
gpg --list-secret-keys --keyid-format=long
dpkg-buildpackage --force-sign
# pwd
# dpkg-buildpackage -us -uc -b