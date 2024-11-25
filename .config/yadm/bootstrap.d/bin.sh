#!/bin/bash
set -euo pipefail

system_type=$(uname -s)

if ! _has curl; then
    echo "Installing curl"
    sudo apt install -y curl
fi

if ! _has wget; then
    echo "Installing wget"
    sudo apt install -y wget
fi

if ! _has zoxide; then
    echo "Installing zoxide"
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi


if ! _has fd; then
    echo "Installing fd-find"
    curl -fsSLO https://github.com/sharkdp/fd/releases/download/v10.1.0/fd-v10.1.0-x86_64-unknown-linux-gnu.tar.gz
    mkdir -pv ~/.fd-find
    tar -xf fd-v10.1.0-x86_64-unknown-linux-gnu.tar.gz --strip-components=1 -C ~/.fd-find
    rm fd-v10.1.0-x86_64-unknown-linux-gnu.tar.gz
    ln -sf "$HOME/.fd-find/fd" "$HOME/.local/bin/fd"
    ln -sf "$HOME/.fd-find/autocomplete/_fd" "$ZSH_CUSTOM/completions/_fd"
    ln -sf "$HOME/.fd-find/fd.1" "$HOME/.local/share/man/man1/fd.1"
fi


if ! _has rg; then
    echo "Installing ripgrep"
    curl -fsSLO https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep-14.1.0-aarch64-unknown-linux-gnu.tar.gz
    mkdir -pv ~/.ripgrep
    tar -xf ripgrep-14.1.0-aarch64-unknown-linux-gnu.tar.gz --strip-components=1 -C ~/.ripgrep
    rm ripgrep-14.1.0-aarch64-unknown-linux-gnu.tar.gz
    ln -sf "$HOME/.ripgrep/rg" "$HOME/.local/bin/rg"
    ln -sf "$HOME/.ripgrep/complete/_rg" "$ZSH_CUSTOM/completions/_rg"
    ln -sf "$HOME/.ripgrep/doc/rg.1" "$HOME/.local/share/man/man1/rg.1"
fi


if ! _has fzf; then
    echo "Installing fzf"
    rm -rf ~/.fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi


if ! _has bat; then
    echo "Installing bat"
    curl -fsSLO https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-aarch64-unknown-linux-gnu.tar.gz
    mkdir -pv ~/.bat
    tar -xf bat-v0.24.0-aarch64-unknown-linux-gnu.tar.gz --strip-components=1 -C ~/.bat
    rm bat-v0.24.0-aarch64-unknown-linux-gnu.tar.gz
    ln -sf "$HOME/.bat/bat" "$HOME/.local/bin/bat"
    ln -sf "$HOME/.bat/autocomplete/bat.zsh" "$ZSH_CUSTOM/completions/bat.zsh"
    ln -sf "$HOME/.bat/bat.1" "$HOME/.local/share/man/man1/bat.1"
fi


if ! _has tree; then
    echo "Installing tree"
    sudo apt install -y tree
fi


if ! volta -v &>/dev/null; then
    echo "Installing volta"
    curl https://get.volta.sh | bash -s -- --skip-setup
fi


if ! node -v &>/dev/null; then
    echo "Installing node"
    ~/.volta/bin/volta install node
fi


if ! _has tldr; then
    echo "Installing tldr"
    ~/.volta/bin/volta install tldr
    mkdir -pv "$ZSH_CUSTOM/plugins/tldr"
    ln -sf "$HOME/.volta/tools/shared/tldr/bin/completion/zsh/_tldr" "$ZSH_CUSTOM/completions/_tldr"
    echo 'Tldr cache will be downloaded on the first run'
fi


if ! _has ncdu; then
    echo "Installing ncdu"
    sudo apt update && sudo apt install -y ncdu
fi

if ! _has btop; then
    echo "Installing btop"
    sudo apt install -y btop
fi

if ! _has ansible; then
    echo "Installing ansible"
    sudo apt install -y ansible
fi

if ! _has ansible-lint; then
    echo "Installing ansible-lint"
    sudo apt install -y ansible-lint
fi

if ! _has ffmpeg; then
    echo "Installing ffmpeg"
    curl -fsSL https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz -o ffmpeg-latest.tar.xz
    mkdir -p ~/.ffmpeg
    tar -xf ffmpeg-latest.tar.xz --strip-components=1 -C ~/.ffmpeg
    rm ffmpeg-latest.tar.xz
    ln -sf "$HOME/.ffmpeg/bin/ffmpeg" "$HOME/.local/bin/ffmpeg"
fi

if ! _has gifsicle; then
    echo "Installing gifsicle"
    sudo apt install -y gifsicle
fi

if ! _has pipx; then
    echo "Installing pipx"
    sudo apt install -y pipx
    register-python-argcomplete --shell zsh pipx > $ZSH_CUSTOM/completions/_pipx
fi

if ! _has yt-dlp; then
    echo "Installing yt-dlp"
    # use the nightly version
    pipx install --pip-args '\--pre' yt-dlp
fi

if ! _has figlet; then
    echo "Installing figlet"
    sudo apt install -y figlet
fi

if ! _has jq; then
    echo "Installing jq"
    sudo apt install -y jq
fi

if ! _has hyperfine; then
    echo "Installing hyperfine"
    sudo apt install -y hyperfine
fi

if ! _has zip; then
    echo "Installing zip"
    sudo apt install -y zip
fi

if ! _has aws; then
    echo "Installing AWS CLI"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
        && unzip "awscliv2.zip" \
        && sudo ./aws/install \
        && rm "awscliv2.zip"
fi

if ! _has delta; then
    echo "Installing git-delta"
    curl -fsSL https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz -o "delta.tar.gz"
    mkdir -p ~/.delta
    tar -xf delta.tar.gz --strip-components=1 -C ~/.delta
    ln -sf "$HOME/.delta/delta" "$HOME/.local/bin/delta"
    rm "delta.tar.gz"
fi

if ! _has arkade; then
    echo "Installing arkade"
    curl -sLS https://get.arkade.dev | sudo sh
    # change path temporarily; add to .zshrc for permanent effect
    path+=($HOME/.arkade/bin/)
    export PATH
    arkade completion zsh > $ZSH_CUSTOM/completions/_arkade
fi

if ! _has kubectl; then
    echo "Installing kubectl"
	arkade get kubectl
    kubectl completion zsh > $ZSH_CUSTOM/completions/_kubectl
fi

if ! _has kubectx; then
	echo "Installing kubectx"
	arkade get kubectx
fi

if ! _has kubens; then
	echo "Installing kubens"
	arkade get kubens
fi

if ! _has helm; then
	echo "Installing helm"
	arkade get helm
    helm completion zsh > $ZSH_CUSTOM/completions/_helm
fi

if ! _has stern; then
	echo "Installing stern"
	arkade get stern
    stern --completion zsh > $ZSH_CUSTOM/completions/_stern
fi

if ! _has cmctl; then
	echo "Installing cmctl - a CLI for cert-manager"
	arkade get cmctl
    cmctl completion zsh > $ZSH_CUSTOM/completions/_cmctl
fi

