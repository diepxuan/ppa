A PPA repository for DiepXuan Personal Package Archives

#### Use Apt package manager
```bash
sudo add-apt-repository ppa:caothu91/ppa
```

#### Use own custom installer
```bash
curl -s https://diepxuan.github.io/ppa/install.sh | sudo bash
```

#### Manual install
```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CF8545DBEDD9351A
sudo curl -SsL -o /etc/apt/sources.list.d/caothu91-ubuntu-ppa-focal.list https://diepxuan.github.io/ppa/caothu91-ubuntu-ppa-focal.list
sudo apt update
sudo apt install ductn

sudo systemctl daemon-reload
sudo systemctl enable ductnd
sudo systemctl restart ductnd
```
