#!/bin/bash
set -euo pipefail

log_install_pre 'bootstrap preflight'

require_cmd bash
require_cmd curl
require_cmd git
require_cmd rsync
require_cmd sudo

if _is_macos; then
    require_cmd xcode-select
    if ! xcode-select -p >/dev/null 2>&1; then
        echo "Error: Xcode Command Line Tools are required." >&2
        echo "Install them first with: xcode-select --install" >&2
        return 1
    fi
    require_cmd brew
elif _is_linux; then
    require_cmd apt
else
    echo "Error: unsupported OS: $(uname -s)" >&2
    return 1
fi

