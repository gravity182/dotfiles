#!/bin/bash
set -euo pipefail

if _is_macos; then
    brew_bin=''

    if [[ -x /opt/homebrew/bin/brew ]]; then
        brew_bin='/opt/homebrew/bin/brew'
    elif [[ -x /usr/local/bin/brew ]]; then
        brew_bin='/usr/local/bin/brew'
    elif _has brew; then
        brew_bin="$(command -v brew)"
    fi

    if [[ -z "$brew_bin" ]]; then
        log_install_pre 'brew'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [[ -x /opt/homebrew/bin/brew ]]; then
            brew_bin='/opt/homebrew/bin/brew'
        elif [[ -x /usr/local/bin/brew ]]; then
            brew_bin='/usr/local/bin/brew'
        fi
    fi

    if [[ -z "$brew_bin" ]]; then
        echo "Error: Homebrew binary not found after installation." >&2
        return 1
    fi

    eval "$("$brew_bin" shellenv)"
fi
