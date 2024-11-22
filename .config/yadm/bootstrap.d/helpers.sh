#!/bin/bash
set -eu

# check whether the given command is executable or aliased
function _has() {
    return $(command -v $1 &>/dev/null)
}

