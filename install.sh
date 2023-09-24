sudo grep -r "deb http://ppa.launchpad.net/ondrej/php/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/*.list >/dev/null 2>&1 && return

command -v add-apt-repository >/dev/null 2>&1 && (
  sudo add-apt-repository ppa:ondrej/php -y
) || (
  cat <<EOF | sudo tee /etc/apt/sources.list.d/ondrej-ubuntu-php-focal.list >/dev/null &&
deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu focal main
EOF
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
)

# sudo add-apt-repository ppa:caothu91/ppa

### Install public key for ppa.launchpad.net
# Manual key
# curl -SsL https://diepxuan.github.io/ppa/key.gpg | sudo apt-key add -

# Ubuntu key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CF8545DBEDD9351A
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7E0EC917A5074BD3

# Older version
# gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv CF8545DBEDD9351A
# gpg --export --armor CF8545DBEDD9351A | sudo apt-key add -


# Add source list
sudo curl -SsL -o /etc/apt/sources.list.d/caothu91-ubuntu-ppa-focal.list https://diepxuan.github.io/ppa/caothu91-ubuntu-ppa-focal.list

# Install package
sudo apt update
sudo apt install ductn

# Register and start service
# sudo systemctl daemon-reload
# sudo systemctl enable ductnd
# sudo systemctl restart ductnd
