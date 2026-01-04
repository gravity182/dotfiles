#!/bin/bash
set -euo pipefail

system_type=$(uname -s)
system_arch=$(uname -m)

echo -e "${BOLD_GREEN}Detected system arch: ${BOLD_YELLOW}$system_arch${RESET}"

# change path temporarily
export PATH=$PATH:$HOME/.local/bin

mkdir -pv ~/.local/bin
mkdir -pv ~/.local/share/man/{man1,man5}

if ! _has curl; then
    log_install_pre 'curl'
    sudo apt install -y curl
fi

if ! _has wget; then
    log_install_pre 'wget'
    sudo apt install -y wget
fi

if ! _has dig; then
    log_install_pre 'dnsutils'
    sudo apt install -y dnsutils
fi

if ! _has zoxide; then
    log_install_pre 'zoxide'
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

if ! _has eza; then
    log_install_pre 'eza - a modern alternative to ls'
    version='0.20.10'
    if [[ $system_arch == "arm64" ]]; then
        curl -fsSL https://github.com/eza-community/eza/releases/download/v$version/eza_aarch64-unknown-linux-gnu.tar.gz -o eza.tar.gz
    else
        curl -fsSL https://github.com/eza-community/eza/releases/download/v$version/eza_x86_64-unknown-linux-gnu.tar.gz -o eza.tar.gz
    fi
    curl -fsSL https://github.com/eza-community/eza/releases/download/v$version/completions-$version.tar.gz -o eza-completions.tar.gz
    curl -fsSL https://github.com/eza-community/eza/releases/download/v$version/man-$version.tar.gz -o eza-man.tar.gz

    mkdir -pv ~/.eza/{completions,man}

    tar -xf eza.tar.gz --strip-components=1 -C ~/.eza
    tar -xf eza-completions.tar.gz --strip-components=3 -C ~/.eza/completions
    tar -xf eza-man.tar.gz --strip-components=3 -C ~/.eza/man
    rm -f eza.tar.gz
    rm -f eza-completions.tar.gz
    rm -f eza-man.tar.gz

    ln -sf "$HOME/.eza/eza" "$HOME/.local/bin/eza"
    ln -sf "$HOME/.eza/completions/_eza" "$ZSH_CUSTOM/completions/_eza"
    ln -sf "$HOME/.eza/man/eza.1" "$HOME/.local/share/man/man1/eza.1"
    ln -sf "$HOME/.eza/man/eza_colors.5" "$HOME/.local/share/man/man5/eza_colors.5"
    ln -sf "$HOME/.eza/man/eza_colors-explanation.5" "$HOME/.local/share/man/man5/eza_colors-explanation.5"
fi


if ! _has fd; then
    log_install_pre 'fd-find'
    version='v10.2.0'
    if [[ $system_arch == 'arm64' ]]; then
        curl -fsSL https://github.com/sharkdp/fd/releases/download/$version/fd-$version-aarch64-unknown-linux-gnu.tar.gz -o fd.tar.gz
    else
        curl -fsSL https://github.com/sharkdp/fd/releases/download/$version/fd-$version-x86_64-unknown-linux-gnu.tar.gz -o fd.tar.gz
    fi
    mkdir -pv ~/.fd-find
    tar -xf fd.tar.gz --strip-components=1 -C ~/.fd-find
    rm fd.tar.gz
    ln -sf "$HOME/.fd-find/fd" "$HOME/.local/bin/fd"
    ln -sf "$HOME/.fd-find/autocomplete/_fd" "$ZSH_CUSTOM/completions/_fd"
    ln -sf "$HOME/.fd-find/fd.1" "$HOME/.local/share/man/man1/fd.1"
fi


if ! _has rg; then
    log_install_pre 'ripgrep'
    if [[ $system_arch == 'arm64' ]]; then
        curl -fsSL https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-aarch64-unknown-linux-gnu.tar.gz -o ripgrep.tar.gz
    else
        curl -fsSL https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz -o ripgrep.tar.gz
    fi
    mkdir -pv ~/.ripgrep
    tar -xf ripgrep.tar.gz --strip-components=1 -C ~/.ripgrep
    rm ripgrep.tar.gz
    ln -sf "$HOME/.ripgrep/rg" "$HOME/.local/bin/rg"
    ln -sf "$HOME/.ripgrep/complete/_rg" "$ZSH_CUSTOM/completions/_rg"
    ln -sf "$HOME/.ripgrep/doc/rg.1" "$HOME/.local/share/man/man1/rg.1"
fi


if ! _has fzf; then
    log_install_pre 'fzf'
    rm -rf ~/.fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi


if ! _has bat; then
    log_install_pre 'bat'
    if [[ $system_arch == 'arm64' ]]; then
        curl -fsSL https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-aarch64-unknown-linux-gnu.tar.gz -o bat.tar.gz
    else
        curl -fsSL https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz -o bat.tar.gz
    fi
    mkdir -pv ~/.bat
    tar -xf bat.tar.gz --strip-components=1 -C ~/.bat
    rm bat.tar.gz
    ln -sf "$HOME/.bat/bat" "$HOME/.local/bin/bat"
    ln -sf "$HOME/.bat/autocomplete/bat.zsh" "$ZSH_CUSTOM/completions/bat.zsh"
    ln -sf "$HOME/.bat/bat.1" "$HOME/.local/share/man/man1/bat.1"
fi


if ! _has tree; then
    log_install_pre 'tree'
    sudo apt install -y tree
fi


if ! volta -v &>/dev/null; then
    log_install_pre 'volta'
    curl https://get.volta.sh | bash -s -- --skip-setup
    ~/.volta/bin/volta completions zsh > "$ZSH_CUSTOM/completions/_volta"

fi
export PATH="$HOME/.volta/bin:$PATH"


if ! node -v &>/dev/null; then
    log_install_pre 'node'
    volta install node
fi


if ! _has tldr; then
    log_install_pre 'tldr'
    volta install tldr
    mkdir -pv "$ZSH_CUSTOM/plugins/tldr"
    ln -sf "$HOME/.volta/tools/shared/tldr/bin/completion/zsh/_tldr" "$ZSH_CUSTOM/completions/_tldr"
    echo 'Tldr cache will be downloaded on the first run'
fi


if ! _has ncdu; then
    log_install_pre 'ncdu'
    sudo apt update && sudo apt install -y ncdu
fi

if ! _has btop; then
    log_install_pre 'btop'
    sudo apt install -y btop
fi

if ! _has ansible; then
    log_install_pre 'ansible'
    sudo apt install -y ansible
fi

if ! _has ansible-lint; then
    log_install_pre 'ansible-lint'
    sudo apt install -y ansible-lint
fi

if ! _has ffmpeg; then
    log_install_pre 'ffmpeg'
    if [[ $system_arch == 'arm64' ]]; then
        curl -fsSL https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linuxarm64-gpl.tar.xz -o ffmpeg-latest.tar.xz
    else
        curl -fsSL https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz -o ffmpeg-latest.tar.xz
    fi

    mkdir -p ~/.ffmpeg
    tar -xf ffmpeg-latest.tar.xz --strip-components=1 -C ~/.ffmpeg
    rm ffmpeg-latest.tar.xz
    ln -sf "$HOME/.ffmpeg/bin/ffmpeg" "$HOME/.local/bin/ffmpeg"
    ln -sf "$HOME/.ffmpeg/bin/ffprobe" "$HOME/.local/bin/ffprobe"
    ln -sf "$HOME/.ffmpeg/bin/ffplay" "$HOME/.local/bin/ffplay"
fi

if ! _has yt-dlp; then
    log_install_pre 'yt-dlp'
    version="2025.03.27"
    curl -fsSL "https://github.com/yt-dlp/yt-dlp/releases/download/$version/yt-dlp.tar.gz" -o yt-dlp.tar.gz

    mkdir -p ~/.yt-dlp
    tar -xf yt-dlp.tar.gz --strip-components=1 -C ~/.yt-dlp
    rm yt-dlp.tar.gz
    ln -sf "$HOME/.yt-dlp/yt-dlp" "$HOME/.local/bin/yt-dlp"
    ln -sf "$HOME/.yt-dlp/yt-dlp.1" "$HOME/.local/share/man/man1/yt-dlp.1"
    ln -sf "$HOME/.yt-dlp/completions/zsh/_yt-dlp" "$ZSH_CUSTOM/completions/_yt-dlp"
fi

if ! _has gifsicle; then
    log_install_pre 'gifsicle'
    sudo apt install -y gifsicle
fi

if ! _has uv; then
    log_install_pre 'uv'
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

if ! _has figlet; then
    log_install_pre 'figlet'
    sudo apt install -y figlet
fi

if ! _has jq; then
    log_install_pre 'jq'
    sudo apt install -y jq
fi

if ! _has hyperfine; then
    log_install_pre 'hyperfine'
    sudo apt install -y hyperfine
fi

if ! _has zip; then
    log_install_pre 'zip'
    sudo apt install -y zip
fi

if ! _has aws; then
    log_install_pre 'AWS CLI'
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
        && unzip "awscliv2.zip" \
        && sudo ./aws/install \
        && rm "awscliv2.zip"
fi

if ! _has delta; then
    log_install_pre 'git-delta'
    curl -fsSL https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz -o "delta.tar.gz"
    mkdir -p ~/.delta
    tar -xf delta.tar.gz --strip-components=1 -C ~/.delta
    ln -sf "$HOME/.delta/delta" "$HOME/.local/bin/delta"
    rm "delta.tar.gz"
fi

if ! _has arkade; then
    log_install_pre 'arkade'
    curl -sLS https://get.arkade.dev | sudo sh
    arkade completion zsh > $ZSH_CUSTOM/completions/_arkade
fi
export PATH=$PATH:$HOME/.arkade/bin/

if ! _has kubectl; then
    log_install_pre 'kubectl'
    arkade get kubectl
    kubectl completion zsh > $ZSH_CUSTOM/completions/_kubectl
fi

if ! _has kubectx; then
    log_install_pre 'kubectx'
    arkade get kubectx
fi

if ! _has kubens; then
    log_install_pre 'kubens'
    arkade get kubens
fi

if ! _has k9s; then
    log_install_pre 'k9s'
    arkade get k9s
    k9s completion zsh > $ZSH_CUSTOM/completions/_k9s
fi

if ! _has helm; then
    log_install_pre 'helm'
    arkade get helm
    helm completion zsh > $ZSH_CUSTOM/completions/_helm
fi

if ! _has stern; then
    log_install_pre 'stern'
    arkade get stern
    stern --completion zsh > $ZSH_CUSTOM/completions/_stern
fi

if ! _has cmctl; then
    log_install_pre "cmctl - a CLI for cert-manager"
    arkade get cmctl
    cmctl completion zsh > $ZSH_CUSTOM/completions/_cmctl
fi

