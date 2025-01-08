#!/usr/bin/env bash
#!/bin/bash

APT_CONF_FILE=/etc/apt/apt.conf.d/50build-deb-action

pwd_dir=$(dirname $(realpath "$BASH_SOURCE"))
source_dir=$pwd_dir/${MODULE:-'management'}
source_dir=$(realpath $source_dir 2>/dev/null)
source_dir=${source_dir:-$pwd_dir}

[[ -f /etc/os-release ]] && . /etc/os-release
[[ -f /etc/lsb-release ]] && . /etc/lsb-release
CODENAME=${CODENAME:-$DISTRIB_CODENAME}
CODENAME=${CODENAME:-$VERSION_CODENAME}
CODENAME=${CODENAME:-$UBUNTU_CODENAME}
CODENAME=$(echo "$CODENAME" | tr '[:upper:]' '[:lower:]')

RELEASE=${RELEASE:-$(echo $DISTRIB_DESCRIPTION | awk '{print $2}')}
RELEASE=${RELEASE:-$(echo $VERSION | awk '{print $1}')}
RELEASE=${RELEASE:-$(echo $PRETTY_NAME | awk '{print $2}')}
RELEASE=${RELEASE:-${DISTRIB_RELEASE}}
RELEASE=${RELEASE:-${VERSION_ID}}
RELEASE=$(echo "$RELEASE" | awk -F. '{print $1"."$2}')

DISTRIB=${DISTRIB:-$DISTRIB_ID}
DISTRIB=${DISTRIB:-$ID}
DISTRIB=$(echo "$DISTRIB" | tr '[:upper:]' '[:lower:]')

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
apt-get build-dep -y -- "$source_dir"

locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

echo "$GPG_KEY====" | tr -d '\n' | fold -w 4 | sed '$ d' | tr -d '\n' | fold -w 76 | base64 -di | gpg --batch --import || true
gpg --list-secret-keys --keyid-format=long

version=${version:-"$(dpkg-parsechangelog -S Version -l $source_dir/debian/changelog 2>/dev/null)"}
version=${version:-"$(head -n 1 $source_dir/debian/changelog | awk -F '[()]' '{print $2}')"}
version=${version:-"0.0.0"}
version="${version}-${DISTRIB}-${RELEASE}"

cd $source_dir
dpkg-buildpackage --force-sign