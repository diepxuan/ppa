#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_ONLY=false
for arg in "$@"; do
    case "$arg" in
        --repository-only)
            REPOSITORY_ONLY=true
            ;;
        --help|-h)
            cat <<'USAGE'
Usage: install.sh [--repository-only]

Options:
  --repository-only  Configure the DiepXuan PPA repository only. Do not install ductn.
  --help, -h         Show this help message.
USAGE
            exit 0
            ;;
        *)
            echo "Error: unknown argument: $arg" >&2
            exit 1
            ;;
    esac
done

run_as_sudo() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
        return
    fi

    if command -v sudo >/dev/null 2>&1; then
        sudo "$@"
        return
    fi

    echo "Error: this command requires root privileges or sudo: $*" >&2
    exit 1
}

require_command() {
    local command_name="$1"
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Error: required command not found: $command_name" >&2
        exit 1
    fi
}

detect_codename() {
    local codename=""

    if [[ "${OSTYPE:-}" == darwin* ]] && command -v sw_vers >/dev/null 2>&1; then
        codename=$(sw_vers -productVersion | awk -F '.' '{print $1":"$2}')
    fi

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        codename=${VERSION_CODENAME:-${UBUNTU_CODENAME:-$codename}}
    fi

    if [[ -f /etc/lsb-release ]]; then
        # shellcheck disable=SC1091
        . /etc/lsb-release
        codename=${DISTRIB_CODENAME:-$codename}
    fi

    if [[ -z "$codename" ]]; then
        echo "Error: unable to detect distribution codename." >&2
        exit 1
    fi

    printf '%s\n' "$codename"
}

download_file() {
    local url="$1"
    local output="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$output"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$output" "$url"
    else
        echo "Error: neither curl nor wget is available." >&2
        exit 1
    fi
}

key_fingerprint() {
    local key_file="$1"
    gpg --show-keys --with-colons --fingerprint "$key_file" 2>/dev/null \
        | awk -F: '$1 == "fpr" {print $10; exit}'
}

install_or_refresh_keyring() {
    local temp_dir downloaded_key dearmored_key downloaded_fingerprint installed_fingerprint

    temp_dir=$(mktemp -d)
    downloaded_key="$temp_dir/key.gpg"
    dearmored_key="$temp_dir/diepxuan.gpg"

    cleanup() {
        rm -rf "$temp_dir"
    }
    trap cleanup RETURN

    echo "Downloading DiepXuan PPA signing key..."
    download_file "$KEY_URL" "$downloaded_key"

    downloaded_fingerprint=$(key_fingerprint "$downloaded_key")
    if [[ "$downloaded_fingerprint" != "$EXPECTED_KEY_FINGERPRINT" ]]; then
        echo "Error: downloaded key fingerprint mismatch." >&2
        echo "Expected: $EXPECTED_KEY_FINGERPRINT" >&2
        echo "Actual:   ${downloaded_fingerprint:-unknown}" >&2
        exit 1
    fi

    gpg --batch --yes --dearmor -o "$dearmored_key" "$downloaded_key"

    installed_fingerprint=""
    if [[ -f "$KEYRING_PATH" ]]; then
        installed_fingerprint=$(key_fingerprint "$KEYRING_PATH" || true)
    fi

    if [[ "$installed_fingerprint" == "$EXPECTED_KEY_FINGERPRINT" ]]; then
        echo "GPG keyring is already valid: $KEYRING_PATH"
        return
    fi

    if [[ -n "$installed_fingerprint" ]]; then
        echo "Refreshing invalid or outdated GPG keyring: $KEYRING_PATH"
        echo "Current fingerprint: $installed_fingerprint"
    else
        echo "Installing GPG keyring: $KEYRING_PATH"
    fi

    run_as_sudo install -d -m 0755 "$(dirname "$KEYRING_PATH")"
    run_as_sudo install -m 0644 "$dearmored_key" "$KEYRING_PATH"

    installed_fingerprint=$(key_fingerprint "$KEYRING_PATH")
    if [[ "$installed_fingerprint" != "$EXPECTED_KEY_FINGERPRINT" ]]; then
        echo "Error: installed key fingerprint mismatch." >&2
        echo "Expected: $EXPECTED_KEY_FINGERPRINT" >&2
        echo "Actual:   ${installed_fingerprint:-unknown}" >&2
        exit 1
    fi
}

REPO_URL=${REPO_URL:-"https://ppa.diepxuan.com"}
KEY_URL=${KEY_URL:-"$REPO_URL/key.gpg"}
KEYRING_PATH=${KEYRING_PATH:-"/usr/share/keyrings/diepxuan.gpg"}
SOURCES_LIST_PATH=${SOURCES_LIST_PATH:-"/etc/apt/sources.list.d/diepxuan.list"}
EXPECTED_KEY_FINGERPRINT=${EXPECTED_KEY_FINGERPRINT:-"C8BD5D6C638E8A11938929267E0EC917A5074BD3"}
CODENAME=${CODENAME:-$(detect_codename)}

require_command gpg
require_command gpgconf

install_or_refresh_keyring

repo_line="deb [signed-by=$KEYRING_PATH] $REPO_URL $CODENAME main"
echo "Configuring repository: $repo_line"
printf '%s\n' "$repo_line" | run_as_sudo tee "$SOURCES_LIST_PATH" >/dev/null

run_as_sudo apt-get update

if [[ "$REPOSITORY_ONLY" == "false" ]]; then
    run_as_sudo apt install ductn -y --purge --auto-remove
else
    echo "Repository setup complete. Install ductn manually with: sudo apt install ductn"
fi
