#!/usr/bin/env bash

[[ "$OSTYPE" == "darwin"* ]] &&
    CODENAME=$(sw_vers -productVersion | awk -F '.' '{print $1"."$2}')
[[ -f /etc/os-release ]] && . /etc/os-release
[[ -f /etc/lsb-release ]] && . /etc/lsb-release
CODENAME=${CODENAME:-$DISTRIB_CODENAME}
CODENAME=${CODENAME:-$VERSION_CODENAME}
CODENAME=${CODENAME:-$UBUNTU_CODENAME}
CODENAME=${CODENAME:-"unknown"}

run_as_sudo() {
    _SUDO=sudo
    command -v sudo &>/dev/null || _SUDO=''
    echo "Running as sudo: $*"
    if [[ $EUID -ne 0 ]]; then
        $_SUDO $@
    else
        $@
    fi
}
SUDO=${SUDO:-'run_as_sudo'}

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
# Kiểm tra gpg có sẵn hay không
if ! command -v gpg &>/dev/null; then
    # Kiểm tra hệ điều hành và cài đặt tương ứng
    if [[ -f /etc/debian_version ]]; then
        # Dành cho Ubuntu/Debian
        $SUDO apt update
        $SUDO apt install -y gnupg
    fi
fi

[[ ! -f /usr/share/keyrings/diepxuan.gpg ]] &&
    curl -fsSL "$KEY_URL" | $SUDO gpg --dearmor -o /usr/share/keyrings/diepxuan.gpg

# Thêm repository vào sources.list.d
# echo "deb [signed-by=/usr/share/keyrings/ppa.gpg] $REPO_URL $UBUNTU_VERSION main" | $SUDO tee /etc/apt/sources.list.d/ppa.list
# echo "deb [trusted=yes] $REPO_URL $CODENAME main" | $SUDO tee /etc/apt/sources.list.d/diepxuan.list
echo "deb [signed-by=/usr/share/keyrings/diepxuan.gpg] $REPO_URL $CODENAME main" | $SUDO tee /etc/apt/sources.list.d/diepxuan.list

# Cập nhật và cài đặt gói
$SUDO apt-get update
# echo "PPA added successfully. Now you can install packages using 'sudo apt install <package-name>'."
$SUDO apt install ductn -y --purge --auto-remove
