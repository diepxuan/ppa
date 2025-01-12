#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u

export DEBIAN_FRONTEND=noninteractive

# Usage:
#   error MESSAGE
error() {
    echo "::error::$*"
}

# Usage:
#   end_group
end_group() {
    echo "::endgroup::"
}

# Usage:
#   start_group GROUP_NAME
start_group() {
    echo "::group::$*"
}

env() {
    GITHUB_ENV=${GITHUB_ENV:-.env}
    param=$1
    value="${@:2}"
    grep -q "^$param=" $GITHUB_ENV &&
        sed -i "s|^$param=.*|$param=$value|" $GITHUB_ENV ||
        echo "$param=$value" >>$GITHUB_ENV
    export $param="$value"
    echo $param: $value
}

SUDO=sudo
command -v sudo &>/dev/null || SUDO=''

start_group Dynamically set environment variable
# directory
env source_dir $(dirname $(realpath "$BASH_SOURCE"))
env source_var $(realpath $source_dir/var)
env source_lib $(realpath $source_dir/var/lib)
env debian_dir $(realpath $source_dir/debian)
env pwd_dir $(realpath $(dirname $source_dir))
env dists_dir $(realpath $pwd_dir/dists)
env ppa_dir $(realpath $pwd_dir/ppa)

# user evironment
env email ductn@diepxuan.com
env DEBEMAIL ductn@diepxuan.com
env EMAIL ductn@diepxuan.com
env DEBFULLNAME Tran Ngoc Duc
env NAME Tran Ngoc Duc
env GIT_COMMITTER_MESSAGE $GIT_COMMITTER_MESSAGE

# gpg key
env GPG_KEY_ID $GPG_KEY_ID
env DEB_SIGN_KEYID $(gpg --list-keys --with-colons --fingerprint | awk -F: '/fpr:/ {print $10; exit}')
# env DEB_SIGN_KEYID $DEB_SIGN_KEYID

# debian
env changelog $(realpath $debian_dir/changelog)
env control $(realpath $debian_dir/control)
env controlin $(realpath $debian_dir/control.in)
env rules $(realpath $debian_dir/rules)
env timelog "$(Lang=C date -R)"

# plugin
env repository $repository
env owner $(echo $repository | cut -d '/' -f1)
env project $(echo $repository | cut -d '/' -f2)
env module $(echo $project | sed 's/^php-//g')

# os evironment
[[ -f /etc/os-release ]] && . /etc/os-release
[[ -f /etc/lsb-release ]] && . /etc/lsb-release
CODENAME=${CODENAME:-$DISTRIB_CODENAME}
CODENAME=${CODENAME:-$VERSION_CODENAME}
CODENAME=${CODENAME:-$UBUNTU_CODENAME}

RELEASE=${RELEASE:-$(echo $DISTRIB_DESCRIPTION | awk '{print $2}')}
RELEASE=${RELEASE:-$(echo $VERSION | awk '{print $1}')}
RELEASE=${RELEASE:-$(echo $PRETTY_NAME | awk '{print $2}')}
RELEASE=${RELEASE:-${DISTRIB_RELEASE}}
RELEASE=${RELEASE:-${VERSION_ID}}
# RELEASE=$(echo "$RELEASE" | awk -F. '{print $1"."$2}')
RELEASE=$(echo "$RELEASE" | cut -d. -f1-2)
RELEASE=$(echo "$RELEASE" | tr '[:upper:]' '[:lower:]')
RELEASE=${RELEASE//[[:space:]]/}
RELEASE=${RELEASE%.}

DISTRIB=${DISTRIB:-$DISTRIB_ID}
DISTRIB=${DISTRIB:-$ID}
DISTRIB=$(echo "$DISTRIB" | tr '[:upper:]' '[:lower:]')

env CODENAME $CODENAME
env RELEASE $RELEASE
env DISTRIB $DISTRIB
end_group

start_group "add apt source"
APT_CONF_FILE=/etc/apt/apt.conf.d/50build-deb-action

cat | $SUDO tee "$APT_CONF_FILE" <<-EOF
APT::Get::Assume-Yes "yes";
APT::Install-Recommends "no";
Acquire::Languages "none";
quiet "yes";
EOF

# debconf has priority “required” and is indirectly depended on by some
# essential packages. It is reasonably safe to blindly assume it is installed.
printf "man-db man-db/auto-update boolean false\n" | $SUDO debconf-set-selections

[[ ! -f /etc/apt/trusted.gpg.d/microsoft.asc ]] &&
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc |
    $SUDO tee /etc/apt/trusted.gpg.d/microsoft.asc
[[ ! -f /etc/apt/trusted.gpg.d/microsoft.asc ]] &&
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc |
    $SUDO gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

[[ ! -f /etc/apt/sources.list.d/prod.list ]] &&
    ! grep -q 'https://packages.microsoft.com' /etc/apt/sources.list /etc/apt/sources.list.d/* &&
    curl -fsSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list |
    $SUDO tee /etc/apt/sources.list.d/prod.list >/dev/null

# add repository for install missing depends
# $SUDO apt install software-properties-common
# $SUDO add-apt-repository ppa:ondrej/php -y
end_group

start_group Install Build Source Dependencies
$SUDO apt update
# shellcheck disable=SC2086
$SUDO apt build-dep $INPUT_APT_OPTS -- "$source_dir" || true
$SUDO apt-get build-dep -y -- "$source_dir" || true

$SUDO apt-get install -y dpkg-dev libdpkg-perl dput tree devscripts libdistro-info-perl software-properties-common debhelper-compat
$SUDO apt-get install -y build-essential debhelper fakeroot gnupg reprepro wget curl git sudo vim locales lsb-release

# In theory, explicitly installing dpkg-dev would not be necessary. `apt-get
# build-dep` will *always* install build-essential which depends on dpkg-dev.
# But let’s be explicit here.
# shellcheck disable=SC2086
$SUDO apt install $INPUT_APT_OPTS -- dpkg-dev libdpkg-perl dput tree devscripts $INPUT_EXTRA_BUILD_DEPS
$SUDO apt install $INPUT_APT_OPTS -- libdistro-info-perl $INPUT_EXTRA_BUILD_DEPS
end_group

start_group View Source Code
echo $source_dir
ls -la $source_dir
echo $debian_dir
ls -la $debian_dir
end_group

# Update os release latest
# old_release_os=$(cat $changelog | head -n 1 | awk '{print $2}' | cut -d '+' -f2 | cut -d '~' -f1)
# sed -i -e "0,/$old_release_os/ s/$old_release_os/${DISTRIB}${RELEASE}/g" $changelog

# Update os codename
# old_codename_os=$(cat $changelog | head -n 1 | awk '{print $3}')
# sed -i -e "0,/$old_codename_os/ s/$old_codename_os/$CODENAME;/g" $changelog

# Update time building
# BUILDPACKAGE_EPOCH=${BUILDPACKAGE_EPOCH:-$(date -R)}
# sed -i -e "0,/<$email>  .*/ s/<$email>  .*/<$email>  $BUILDPACKAGE_EPOCH/g" $changelog

start_group Update Package Configuration in Changelog
cd $source_dir

release_tag=$($source_dir/ductn version:newrelease)

# old_project=$(cat $changelog | head -n 1 | awk '{print $1}' | sed 's|[()]||g')
# old_release_tag=$(cat $changelog | head -n 1 | awk '{print $2}' | sed 's|[()]||g')
# old_codename_os=$(cat $changelog | head -n 1 | awk '{print $3}' | sed 's|;||g')
# package_clog=${package_clog:-$(git log -1 --pretty=format:"%h %s" -- $source_dir/)}
package_clog=${package_clog:-$GIT_COMMITTER_MESSAGE}
package_clog=${package_clog:-"Update package"}

# sed -i -e "s|$old_project|$_project|g" $changelog

# sed -i -e "s|$old_release_tag|$release_tag|g" $changelog
# sed -i -e "s|$old_codename_os|$CODENAME|g" $changelog
# sed -i -e "s|<$email>  .*|<$email>  $timelog|g" $changelog
# dch -D $CODENAME
dch --newversion $release_tag+$DISTRIB~$RELEASE --distribution $CODENAME "$package_clog"
# dch --newversion $release_tag --distribution $CODENAME "$package_clog"
# dch --newversion $release_tag~$DISTRIB$RELEASE
# dch -a "$package_clog"
cd -
end_group

start_group Show log
echo $control
cat $control || true
echo $controlin
cat $controlin || true
echo $rules
cat $rules || true
end_group

start_group Show changelog
cat $changelog
end_group

start_group Show package changelog
echo $package_clog
end_group

start_group log GPG key before build
gpg --list-secret-keys --keyid-format=long
end_group

start_group Building package binary
# shellcheck disable=SC2086
dpkg-buildpackage --force-sign
end_group

start_group Building package source
# shellcheck disable=SC2086
dpkg-buildpackage --force-sign -S
end_group

start_group Move build artifacts
regex='^php.*(.deb|.ddeb|.buildinfo|.changes|.dsc|.tar.xz|.tar.gz|.tar.[[:alpha:]]+)$'
regex='.*(.deb|.ddeb|.buildinfo|.changes|.dsc|.tar.xz|.tar.gz|.tar.[[:alpha:]]+)$'
mkdir -p $dists_dir

while read -r file; do
    mv -vf "$source_dir/$file" "$dists_dir/" || true
done < <(ls $source_dir/ | grep -E $regex)

while read -r file; do
    mv -vf "$pwd_dir/$file" "$dists_dir/" || true
done < <(ls $pwd_dir/ | grep -E $regex)

ls -la $dists_dir
end_group

start_group Publish Package to Launchpad
cat | tee ~/.dput.cf <<-EOF
[caothu91ppa]
fqdn = ppa.launchpad.net
method = ftp
incoming = ~caothu91/ubuntu/ppa/
login = anonymous
allow_unsigned_uploads = 0
EOF

# package=$(ls -a $dists_dir | grep _source.changes | head -n 1)

# [[ -n $package ]] &&
#     package=$dists_dir/$package &&
#     [[ -f $package ]] &&
#     dput caothu91ppa $package || true

while read -r package; do
    dput caothu91ppa $pwd_dir/$package || true
done < <(ls $dists_dir | grep -E '.*(_source.changes)$')
end_group
