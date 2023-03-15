# sudo add-apt-repository ppa:caothu91/ppa

### Install public key for ppa.launchpad.net
# Manual key
# curl -SsL https://diepxuan.github.io/ppa/key.gpg | sudo apt-key add -

# Ubuntu key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CF8545DBEDD9351A

# Older version
# gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv CF8545DBEDD9351A
# gpg --export --armor CF8545DBEDD9351A | sudo apt-key add -


# Add source list
sudo curl -SsL -o /etc/apt/sources.list.d/caothu91-ubuntu-ppa-focal.list https://diepxuan.github.io/ppa/caothu91-ubuntu-ppa-focal.list

# Install package
sudo apt update
sudo apt install ductn

# Register and start service
sudo systemctl daemon-reload
sudo systemctl enable ductnd
sudo systemctl restart ductnd
