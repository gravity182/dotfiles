#!/bin/bash
set -eu

if ! _has tmux; then
    log_install_pre 'tmux'
    sudo apt install -y tmux
fi

log_install_pre 'tmux plugins'
# start a server but don't attach to it
tmux start-server
# # create a new session but don't attach to it either
tmux new-session -d
# # install the plugins
~/.tmux/plugins/tpm/scripts/install_plugins.sh
tmux kill-server

