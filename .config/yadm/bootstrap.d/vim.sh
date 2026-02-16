#!/bin/bash
set -euo pipefail

echo "Installing VIM"

# vim with a system clipboard support
_pkg_install vim vim-gtk3

echo "Installing Vim plugins"
vim +PlugInstall +qall
