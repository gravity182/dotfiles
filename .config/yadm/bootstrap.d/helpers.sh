#!/bin/bash
set -eu

# check whether the given command is executable or aliased
function _has() {
    return $(command -v $1 &>/dev/null)
}

function log_install_pre() {
    echo "--------------------------------------"
    echo -e "${BOLD_YELLOW}Installing $1${RESET}"
    echo "--------------------------------------"
}

