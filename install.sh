#!/usr/bin/env bash

[[ "$OSTYPE" == "darwin"* ]] &&
    CODENAME=$(sw_vers -productVersion | awk -F '.' '{print $1"."$2}')
[[ -f /etc/os-release ]] && . /etc/os-release
[[ -f /etc/lsb-release ]] && . /etc/lsb-release
CODENAME=${CODENAME:-$DISTRIB_CODENAME}
CODENAME=${CODENAME:-$VERSION_CODENAME}
CODENAME=${CODENAME:-$UBUNTU_CODENAME}
CODENAME=${CODENAME:-"unknown"}

# Xác định URL của repository
REPO_URL="https://ppa.diepxuan.com/"
KEY_URL="$REPO_URL/key.gpg"

# Kiểm tra xem có hỗ trợ phiên bản hiện tại không
# case "$UBUNTU_VERSION" in
#   focal|jammy|bionic)
#     echo "Adding PPA for $UBUNTU_VERSION..."
#     ;;
#   *)
#     echo "Error: $UBUNTU_VERSION is not supported."
#     exit 1
#     ;;
# esac

# Thêm khoá GPG
curl -fsSL "$KEY_URL" | sudo gpg --dearmor -o /usr/share/keyrings/diepxuan.gpg

# Thêm repository vào sources.list.d
# echo "deb [signed-by=/usr/share/keyrings/ppa.gpg] $REPO_URL $UBUNTU_VERSION main" | sudo tee /etc/apt/sources.list.d/ppa.list
# echo "deb [trusted=yes] $REPO_URL $CODENAME main" | sudo tee /etc/apt/sources.list.d/diepxuan.list
echo "deb [signed-by=/usr/share/keyrings/diepxuan.gpg] $REPO_URL $CODENAME main" | sudo tee /etc/apt/sources.list.d/diepxuan.list

# Cập nhật và cài đặt gói
sudo apt-get update
# echo "PPA added successfully. Now you can install packages using 'sudo apt install <package-name>'."