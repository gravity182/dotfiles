#!/bin/bash
set -eu

if ! _has vim; then
    echo "Installing vim"
    sudo apt update && sudo apt install -y vim
fi

echo "Installing Vim plugins"
vim +PlugInstall +qall

