#!/bin/bash
set -eu

if ! _has brew; then
    echo "Installing brew"
    sudo apt update && sudo apt install -y zsh
fi
