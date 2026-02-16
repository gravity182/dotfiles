#!/bin/bash
set -euo pipefail

# bootstrap is sourced by bash; don't rely on zsh-only init files.
# Provide sane defaults for variables used throughout the bootstrap scripts.
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# check whether the given command is executable or aliased
function _has() {
    command -v "$1" &>/dev/null
}

function _is_macos() {
    [[ "$OSTYPE" == darwin* ]]
}

function _is_linux() {
    [[ "$OSTYPE" == linux* ]]
}

# Returns normalized architecture: "arm64" or "x86_64"
function _arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        aarch64|arm64) echo "arm64" ;;
        x86_64|amd64)  echo "x86_64" ;;
        *)             echo "$arch" ;;
    esac
}

# Track whether `apt update` was already executed during the current bootstrap run.
_APT_UPDATED=0

function _apt_update_once() {
    if ! _is_linux; then
        return 0
    fi

    if [[ "$_APT_UPDATED" -eq 1 ]]; then
        return 0
    fi

    if ! _has apt; then
        echo "Error: \`apt\` not found on Linux system." >&2
        return 1
    fi

    sudo apt update
    _APT_UPDATED=1
}

# Install a package using the system package manager.
# Usage: _pkg_install <brew_name> [apt_name]
# If apt_name is omitted, brew_name is used for both.
function _pkg_install() {
    local brew_name="$1"
    local apt_name="${2:-$1}"

    if _is_macos; then
        brew install "$brew_name"
    else
        _apt_update_once
        sudo apt install -y "$apt_name"
    fi
}

# Download and extract a GitHub release archive.
# Handles arch detection, download, extraction, and cleanup.
# Symlinks are tool-specific, so the caller handles those.
#
# Usage: _gh_release_download <repo> <version> <asset_arm64> <asset_x86_64> <dest_dir> [strip_components]
# Example: _gh_release_download "sharkdp/fd" "v10.2.0" \
#              "fd-v10.2.0-aarch64-unknown-linux-gnu.tar.gz" \
#              "fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz" \
#              "$HOME/.fd-find"
function _gh_release_download() {
    local repo="$1"
    local version="$2"
    local asset_arm64="$3"
    local asset_x86="$4"
    local dest="$5"
    local strip="${6:-1}"

    local asset
    if [[ $(_arch) == "arm64" ]]; then
        asset="$asset_arm64"
    else
        asset="$asset_x86"
    fi

    local url="https://github.com/$repo/releases/download/$version/$asset"
    local tmpfile="/tmp/$asset"

    curl -fsSL "$url" -o "$tmpfile"
    mkdir -p "$dest"

    if [[ "$asset" == *.tar.* ]]; then
        tar -xf "$tmpfile" --strip-components="$strip" -C "$dest"
    elif [[ "$asset" == *.zip ]]; then
        # Note: unzip does not support --strip-components
        unzip -o "$tmpfile" -d "$dest"
    else
        echo "Error: unsupported archive format: $asset" >&2
        return 1
    fi

    rm -f "$tmpfile"
}

function log_install_pre() {
    echo "--------------------------------------"
    echo -e "${BOLD_YELLOW}Installing $1${RESET}"
    echo "--------------------------------------"
}
