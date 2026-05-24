#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

function doIt() {
    cd ~
    for cmd in bash curl git rsync; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Error: required command '$cmd' was not found." >&2
            exit 1
        fi
    done

    case "$(uname -s)" in
        Darwin)
            if ! command -v xcode-select >/dev/null 2>&1 || ! xcode-select -p >/dev/null 2>&1; then
                echo "Error: Xcode Command Line Tools are required." >&2
                echo "Install them first with: xcode-select --install" >&2
                exit 1
            fi
            ;;
        Linux)
            if ! command -v sudo >/dev/null 2>&1 || ! command -v apt >/dev/null 2>&1; then
                echo "Error: Linux bootstrap requires sudo and apt." >&2
                exit 1
            fi
            ;;
        *)
            echo "Error: unsupported OS: $(uname -s)" >&2
            exit 1
            ;;
    esac

    rm -rf /tmp/dotfiles
    git clone https://github.com/gravity182/dotfiles.git /tmp/dotfiles
    rsync --exclude ".git/" \
        --exclude ".DS_Store" \
        --exclude "docs/" \
        -avh --no-perms /tmp/dotfiles/ .
    ./.config/yadm/bootstrap
}

if [[ "${1:-}" == "--force" ]]; then
    doIt
else
    printf 'This may overwrite existing files in your home directory. Continue? (y/n) '
    read -r answer
    if [[ "$answer" != "${answer#[Yy]}" ]]; then
        doIt
    fi
fi
unset doIt
