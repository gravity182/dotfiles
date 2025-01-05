#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

function doIt() {
    cd ~
    rm -rf /tmp/dotfiles
    git clone https://github.com/blinky-z/dotfiles.git /tmp/dotfiles
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
    read answer
    if [[ "$answer" != "${answer#[Yy]}" ]]; then
        doIt
    fi
fi
unset doIt

