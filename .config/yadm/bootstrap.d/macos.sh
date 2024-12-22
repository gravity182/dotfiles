#!/bin/bash
set -eu

if [[ "$OSTYPE" != "darwin"* ]]; then
    return 0
fi

if ! _has brew; then
    echo "Installing brew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

