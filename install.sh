#!/usr/bin/env bash

# Parse arguments
REPOSITORY_ONLY=false
for arg in "$@"; do
    case $arg in
        --repository-only)
            REPOSITORY_ONLY=true
            shift
            ;;
    esac
done

[[ "$OSTYPE" == "darwin*" ]] &&
    CODENAME=$(sw_vers -productVersion | awk -F '.' '{print $1":"$2}')
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

REPO_URL="https://ppa.diepxuan.com/"
KEY_URL="$REPO_URL/key.gpg"

# Cài gpg nếu thiếu
if ! command -v gpg &>/dev/null; then
    if [[ -f /etc/debian_version ]]; then
        $SUDO apt update
        $SUDO apt install -y gnupg
    fi
fi

# Kiểm tra curl hoặc wget
if command -v curl &>/dev/null; then
    DOWNLOAD_CMD="curl -fsSL"
elif command -v wget &>/dev/null; then
    DOWNLOAD_CMD="wget -qO-"
else
    echo "Error: Neither curl nor wget is available."
    exit 1
fi

# Thêm GPG key
[[ ! -f /usr/share/keyrings/diepxuan.gpg ]] &&
    $DOWNLOAD_CMD "$KEY_URL" | $SUDO gpg --dearmor -o /usr/share/keyrings/diepxuan.gpg

# Thêm repository
echo "deb [signed-by=/usr/share/keyrings/diepxuan.gpg] $REPO_URL $CODENAME main" | $SUDO tee /etc/apt/sources.list.d/diepxuan.list

# Cập nhật
$SUDO apt-get update

# Chỉ cài ductn nếu KHÔNG truyền --repository-only
if [[ "$REPOSITORY_ONLY" == "false" ]]; then
    $SUDO apt install ductn -y --purge --auto-remove
else
    echo "Repository setup complete. Install ductn manually with: sudo apt install ductn"
fi
