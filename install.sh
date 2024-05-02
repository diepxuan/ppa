grep -r "deb http://ppa.launchpad.net/ondrej/php/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/*.list >/dev/null 2>&1 && return
grep -r "deb http://ppa.launchpad.net/caothu91/ppa/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/*.list >/dev/null 2>&1 && return

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CF8545DBEDD9351A
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7E0EC917A5074BD3

command -v add-apt-repository >/dev/null 2>&1 && (
    add-apt-repository ppa:ondrej/php -y
) || cat <<EOF | tee /etc/apt/sources.list.d/ondrej-ubuntu-php-focal.list >/dev/null &&
deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu focal main
EOF

command -v add-apt-repository >/dev/null 2>&1 && (
    add-apt-repository ppa:caothu91/ppa -y
) || cat <<EOF | tee /etc/apt/sources.list.d/caothu91-ubuntu-ppa-focal.list >/dev/null
deb http://ppa.launchpad.net/caothu91/ppa/ubuntu focal main
# deb-src http://ppa.launchpad.net/caothu91/ppa/ubuntu focal main
EOF

### Install public key for ppa.launchpad.net
# Manual key
# curl -SsL https://diepxuan.github.io/ppa/key.gpg | apt-key add -

# Install package
apt update
apt install ductn
