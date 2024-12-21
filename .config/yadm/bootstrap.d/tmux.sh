#!/bin/bash
set -euo pipefail

if ! _has tmux; then
    log_install_pre 'tmux'
    sudo apt install -y tmux
fi

log_install_pre 'tmux plugins'
[[ -d ~/.tmux/plugins/tpm ]] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux start-server
tmux new-session -d
tmux source ~/.tmux.conf
~/.tmux/plugins/tpm/scripts/install_plugins.sh
tmux source ~/.tmux.conf

