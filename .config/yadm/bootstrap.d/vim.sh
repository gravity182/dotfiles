#!/bin/bash
set -eu

echo "Installing VIM"

# vim with a system clipboard support
sudo apt update
sudo apt install -y vim-gtk3

echo "Installing Vim plugins"
vim +PlugInstall +qall

