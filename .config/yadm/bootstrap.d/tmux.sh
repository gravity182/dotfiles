#!/bin/bash
set -euo pipefail

if ! _has tmux; then
    log_install_pre 'tmux'
    _pkg_install tmux
fi

log_install_pre 'tmux plugins'
[[ -d ~/.tmux/plugins/tpm ]] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

_tmux_bootstrap_install_plugins() {
    local tmux_socket="bootstrap-dotfiles-$$"
    local tmux_session="bootstrap-dotfiles"
    local tmux_socket_file="${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/$tmux_socket"
    local tmux_socket_path
    local tmux_status=0

    tmux -L "$tmux_socket" kill-server >/dev/null 2>&1 || true
    rm -f "$tmux_socket_file"

    tmux -L "$tmux_socket" new-session -d -s "$tmux_session" || tmux_status=$?
    if [[ "$tmux_status" -eq 0 ]]; then
        tmux_socket_path="$(tmux -L "$tmux_socket" display-message -p '#{socket_path}')" || tmux_status=$?
        tmux_socket_file="$tmux_socket_path"
    fi
    if [[ "$tmux_status" -eq 0 ]]; then
        tmux -L "$tmux_socket" source-file "$HOME/.tmux.conf" || tmux_status=$?
    fi
    if [[ "$tmux_status" -eq 0 ]]; then
        TMUX="$tmux_socket_path,0,0" "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" || tmux_status=$?
    fi
    if [[ "$tmux_status" -eq 0 ]]; then
        tmux -L "$tmux_socket" source-file "$HOME/.tmux.conf" || tmux_status=$?
    fi

    tmux -L "$tmux_socket" kill-server >/dev/null 2>&1 || true
    rm -f "$tmux_socket_file"
    return "$tmux_status"
}

_tmux_bootstrap_install_plugins
unset -f _tmux_bootstrap_install_plugins
