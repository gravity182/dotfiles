#!/bin/bash
set -eu

echo "Your shell: '$SHELL'"

if ! _has zsh; then
    echo "Installing zsh"
    sudo apt update && sudo apt install -y zsh
fi

echo "Sourcing .zprofile"
source ~/.zprofile
if [[ -z "$ZSH" ]] || [[ -z "$ZSH_CUSTOM" ]]; then
    echo 'Please set $ZSH and $ZSH_CUSTOM vars' >&2
    return 1
fi

# --------------------
# home set up
# --------------------

mkdir -pv ~/.local/{,bin,share{,/man/man1}}


# --------------------
# oh-my-zsh
# --------------------

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing oh-my-zsh"
    git clone --depth=1 "https://github.com/ohmyzsh/ohmyzsh.git" "$HOME/.oh-my-zsh"
fi

mkdir -pv "$ZSH_CUSTOM/"{completions,functions,plugins}


# --------------------
# themes
# --------------------

[[ ! -d "$ZSH_CUSTOM"/themes/powerlevel10k ]] \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM"/themes/powerlevel10k \
    && echo "Downloaded the p10k theme"


# --------------------
# plugins
# --------------------

[[ ! -d "$ZSH_CUSTOM"/plugins/fzf-tab ]] \
    && git clone --depth=1 https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab" \
    && echo "Installed the fzf-tab plugin"
[[ ! -d "$ZSH_CUSTOM"/plugins/zsh-autosuggestions ]] \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" \
    && echo "Installed the zsh-autosuggestions plugin"
[[ ! -d "$ZSH_CUSTOM"/plugins/fast-syntax-highlighting ]] \
    && git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" \
    && echo "Installed the fast-syntax-highlighting plugin"


# --------------------
# zsh completions
# --------------------

# by default zsh can already complete many popular CLIs like cd, cp, git, and so on
# zsh-completions adds even more completions
# see the full list https://github.com/zsh-users/zsh-completions/tree/master/src
[[ ! -d "$ZSH_CUSTOM"/plugins/zsh-completions ]] \
    && git clone --depth=1 https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM"/plugins/zsh-completions \
    && echo "Installed zsh-completions"


# --------------------
# default shell
# --------------------

# set zsh as a default shell
if [[ ! "$SHELL" =~ "zsh" ]]; then
    echo "Setting zsh as a default shell"
    chsh -s $(which zsh)
fi

