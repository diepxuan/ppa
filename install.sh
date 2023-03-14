# Install public key for ppa.launchpad.net
# curl -SsL https://diepxuan.github.io/ppa/key.gpg | sudo apt-key add -
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CF8545DBEDD9351A

# Add source list
#sudo add-apt-repository ppa:caothu91/ppa
sudo curl -SsL -o /etc/apt/sources.list.d/caothu91-ubuntu-ppa-focal.list https://diepxuan.github.io/ppa/caothu91-ubuntu-ppa-focal.list

sudo apt update
sudo apt install ductn
