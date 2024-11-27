#!/bin/bash
set -eu

# check whether the given command is executable or aliased
function _has() {
    return $(command -v $1 &>/dev/null)
}

BOLD_RED='\033[1;31m'
BOLD_YELLOW='\033[1;33m'
BOLD_GREEN='\033[1;32m'
RESET='\033[0m'
function log_install_pre() {
    echo "--------------------------------------"
    echo -e "${BOLD_YELLOW}Installing $1${RESET}"
    echo "--------------------------------------"
}

