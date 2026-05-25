#!/bin/bash
set -euo pipefail

echo -e "${BOLD_GREEN}Detected system arch: ${BOLD_YELLOW}$(_arch)${RESET}"

# change path temporarily
export PATH=$PATH:$HOME/.local/bin

MISE_TOOLS=(
    "node@26.2.0"
    "go@1.26.3"
    "rust@1.95.0"
    "java@corretto-25.0.3.9.1"
    "uv@0.11.16"
)


# ===============
# Basic utilities (Linux-only, macOS has these by default)
# ===============

if _is_linux; then
    if ! _has curl; then
        log_install_pre 'curl'
        _pkg_install curl
    fi

    if ! _has wget; then
        log_install_pre 'wget'
        _pkg_install wget
    fi

    if ! _has dig; then
        log_install_pre 'dnsutils'
        _pkg_install dnsutils
    fi

    if ! _has unzip; then
        log_install_pre 'unzip'
        _pkg_install unzip
    fi

    if ! _has xz; then
        log_install_pre 'xz-utils'
        _pkg_install xz-utils
    fi
fi

# ===============
# Modern CLI tools
# ===============

if ! _has zoxide; then
    log_install_pre 'zoxide'
    if _is_macos; then
        brew install zoxide
    else
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi
fi

if ! _has eza; then
    log_install_pre 'eza - a modern alternative to ls'
    if _is_macos; then
        brew install eza
    else
        version='0.20.10'
        _gh_release_download "eza-community/eza" "v$version" \
            "eza_aarch64-unknown-linux-gnu.tar.gz" \
            "eza_x86_64-unknown-linux-gnu.tar.gz" \
            "$HOME/.eza"

        # eza ships completions and man pages as separate archives
        mkdir -pv ~/.eza/{completions,man}
        curl -fsSL "https://github.com/eza-community/eza/releases/download/v$version/completions-$version.tar.gz" -o /tmp/eza-completions.tar.gz
        curl -fsSL "https://github.com/eza-community/eza/releases/download/v$version/man-$version.tar.gz" -o /tmp/eza-man.tar.gz
        tar -xf /tmp/eza-completions.tar.gz --strip-components=3 -C ~/.eza/completions
        tar -xf /tmp/eza-man.tar.gz --strip-components=3 -C ~/.eza/man
        rm -f /tmp/eza-completions.tar.gz /tmp/eza-man.tar.gz

        ln -sf "$HOME/.eza/eza" "$HOME/.local/bin/eza"
        ln -sf "$HOME/.eza/completions/_eza" "$ZSH_CUSTOM/completions/_eza"
        ln -sf "$HOME/.eza/man/eza.1" "$HOME/.local/share/man/man1/eza.1"
        ln -sf "$HOME/.eza/man/eza_colors.5" "$HOME/.local/share/man/man5/eza_colors.5"
        ln -sf "$HOME/.eza/man/eza_colors-explanation.5" "$HOME/.local/share/man/man5/eza_colors-explanation.5"
    fi
fi

if ! _has fd; then
    log_install_pre 'fd-find'
    if _is_macos; then
        brew install fd
    else
        version='v10.2.0'
        _gh_release_download "sharkdp/fd" "$version" \
            "fd-$version-aarch64-unknown-linux-gnu.tar.gz" \
            "fd-$version-x86_64-unknown-linux-gnu.tar.gz" \
            "$HOME/.fd-find"
        ln -sf "$HOME/.fd-find/fd" "$HOME/.local/bin/fd"
        ln -sf "$HOME/.fd-find/autocomplete/_fd" "$ZSH_CUSTOM/completions/_fd"
        ln -sf "$HOME/.fd-find/fd.1" "$HOME/.local/share/man/man1/fd.1"
    fi
fi

if ! _has rg; then
    log_install_pre 'ripgrep'
    if _is_macos; then
        brew install ripgrep
    else
        version='14.1.1'
        _gh_release_download "BurntSushi/ripgrep" "$version" \
            "ripgrep-$version-aarch64-unknown-linux-gnu.tar.gz" \
            "ripgrep-$version-x86_64-unknown-linux-musl.tar.gz" \
            "$HOME/.ripgrep"
        ln -sf "$HOME/.ripgrep/rg" "$HOME/.local/bin/rg"
        ln -sf "$HOME/.ripgrep/complete/_rg" "$ZSH_CUSTOM/completions/_rg"
        ln -sf "$HOME/.ripgrep/doc/rg.1" "$HOME/.local/share/man/man1/rg.1"
    fi
fi

if _is_macos; then
    if ! brew list --versions fzf >/dev/null 2>&1; then
        log_install_pre 'fzf'
        brew install fzf
    fi
    require_cmd fzf
elif ! _has fzf; then
    log_install_pre 'fzf'
    rm -rf ~/.fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin
    ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
    require_cmd fzf
fi

if ! _has bat; then
    log_install_pre 'bat'
    if _is_macos; then
        brew install bat
    else
        version='v0.24.0'
        _gh_release_download "sharkdp/bat" "$version" \
            "bat-$version-aarch64-unknown-linux-gnu.tar.gz" \
            "bat-$version-x86_64-unknown-linux-gnu.tar.gz" \
            "$HOME/.bat"
        ln -sf "$HOME/.bat/bat" "$HOME/.local/bin/bat"
        ln -sf "$HOME/.bat/autocomplete/bat.zsh" "$ZSH_CUSTOM/completions/bat.zsh"
        ln -sf "$HOME/.bat/bat.1" "$HOME/.local/share/man/man1/bat.1"
    fi
fi

if ! _has tree; then
    log_install_pre 'tree'
    _pkg_install tree
fi

# ===============
# Dev runtimes (mise)
# ===============

if ! _has mise; then
    log_install_pre 'mise'
    if _is_macos; then
        brew install mise
    else
        curl https://mise.run | sh
    fi
fi
export PATH="$HOME/.local/bin:$PATH"
require_cmd mise

log_install_pre 'mise runtimes'
mise install -y --locked "${MISE_TOOLS[@]}"
eval "$(mise activate bash)"
require_cmd node
require_cmd go
require_cmd rustc
require_cmd cargo
require_cmd java
require_cmd javac
require_cmd uv

if ! _has tldr; then
    log_install_pre 'tldr'
    npm install -g tldr
    tldr_completion="$(npm root -g)/tldr/bin/completion/zsh/_tldr"
    require_file "$tldr_completion"
    ln -sf "$tldr_completion" "$ZSH_CUSTOM/completions/_tldr"
    echo 'Tldr cache will be downloaded on the first run'
fi

# ===============
# System utilities
# ===============

if ! _has ncdu; then
    log_install_pre 'ncdu'
    _pkg_install ncdu
fi

if ! _has btop; then
    log_install_pre 'btop'
    _pkg_install btop
fi

if ! _has ansible; then
    log_install_pre 'ansible'
    _pkg_install ansible
fi

if ! _has ansible-lint; then
    log_install_pre 'ansible-lint'
    _pkg_install ansible-lint
fi

if ! _has ffmpeg; then
    log_install_pre 'ffmpeg'
    if _is_macos; then
        brew install ffmpeg
    else
        # ffmpeg uses BtbN builds (not standard GitHub releases)
        if [[ $(_arch) == 'arm64' ]]; then
            curl -fsSL https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linuxarm64-gpl.tar.xz -o /tmp/ffmpeg-latest.tar.xz
        else
            curl -fsSL https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz -o /tmp/ffmpeg-latest.tar.xz
        fi

        mkdir -p ~/.ffmpeg
        tar -xf /tmp/ffmpeg-latest.tar.xz --strip-components=1 -C ~/.ffmpeg
        rm /tmp/ffmpeg-latest.tar.xz
        ln -sf "$HOME/.ffmpeg/bin/ffmpeg" "$HOME/.local/bin/ffmpeg"
        ln -sf "$HOME/.ffmpeg/bin/ffprobe" "$HOME/.local/bin/ffprobe"
        ln -sf "$HOME/.ffmpeg/bin/ffplay" "$HOME/.local/bin/ffplay"
    fi
fi

if ! _has yt-dlp; then
    log_install_pre 'yt-dlp'
    if _is_macos; then
        brew install yt-dlp
    else
        version="2025.03.27"
        # yt-dlp has a single platform-independent tarball
        _gh_release_download "yt-dlp/yt-dlp" "$version" \
            "yt-dlp.tar.gz" "yt-dlp.tar.gz" \
            "$HOME/.yt-dlp"
        ln -sf "$HOME/.yt-dlp/yt-dlp" "$HOME/.local/bin/yt-dlp"
        ln -sf "$HOME/.yt-dlp/yt-dlp.1" "$HOME/.local/share/man/man1/yt-dlp.1"
        ln -sf "$HOME/.yt-dlp/completions/zsh/_yt-dlp" "$ZSH_CUSTOM/completions/_yt-dlp"
    fi
fi

if ! _has gifsicle; then
    log_install_pre 'gifsicle'
    _pkg_install gifsicle
fi

if ! _has figlet; then
    log_install_pre 'figlet'
    _pkg_install figlet
fi

if ! _has jq; then
    log_install_pre 'jq'
    _pkg_install jq
fi

if ! _has hyperfine; then
    log_install_pre 'hyperfine'
    _pkg_install hyperfine
fi

if ! _has zip; then
    log_install_pre 'zip'
    if _is_linux; then
        _pkg_install zip
    fi
    # macOS has zip preinstalled
fi

if { _is_macos && { [[ ! -x /usr/local/bin/aws ]] || [[ ! -x /usr/local/bin/aws_completer ]]; }; } || { ! _is_macos && { ! _has aws || ! _has aws_completer; }; }; then
    log_install_pre 'AWS CLI'
    if _is_macos; then
        curl -fsSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
        sudo installer -pkg "/tmp/AWSCLIV2.pkg" -target /
        rm -f "/tmp/AWSCLIV2.pkg"
        require_executable /usr/local/bin/aws
        require_executable /usr/local/bin/aws_completer
    else
        if [[ $(_arch) == 'arm64' ]]; then
            curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "/tmp/awscliv2.zip"
        else
            curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
        fi
        unzip -q "/tmp/awscliv2.zip" -d /tmp
        sudo /tmp/aws/install --update
        rm -rf "/tmp/awscliv2.zip" /tmp/aws
        require_cmd aws
        require_cmd aws_completer
    fi
fi

if ! _has delta; then
    log_install_pre 'git-delta'
    if _is_macos; then
        brew install git-delta
    else
        version='0.18.2'
        _gh_release_download "dandavison/delta" "$version" \
            "delta-$version-aarch64-unknown-linux-gnu.tar.gz" \
            "delta-$version-x86_64-unknown-linux-gnu.tar.gz" \
            "$HOME/.delta"
        ln -sf "$HOME/.delta/delta" "$HOME/.local/bin/delta"
    fi
fi

if ! _has gh; then
    log_install_pre 'GitHub CLI'
    if _is_macos; then
        brew install gh
    else
        (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
            && sudo mkdir -p -m 755 /etc/apt/keyrings \
            && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
            && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
            && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && sudo apt update \
            && sudo apt install gh -y
    fi
    require_cmd gh
fi

if ! _has lazygit; then
    log_install_pre 'lazygit'
    if _is_macos; then
        brew install lazygit
    else
        _pkg_install lazygit
    fi
    require_cmd lazygit
fi

if _is_macos && ! _has limactl; then
    log_install_pre 'lima'
    brew install lima
    require_cmd limactl
fi

if ! _has docker; then
    log_install_pre 'Docker CLI'
    if _is_macos; then
        brew install docker
    else
        curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
        sudo sh /tmp/get-docker.sh
        rm -f /tmp/get-docker.sh
    fi
    require_cmd docker
fi

if ! docker compose version &>/dev/null; then
    log_install_pre 'Docker Compose'
    if _is_macos; then
        brew install docker-compose
    else
        _pkg_install docker-compose-plugin
    fi
    docker compose version >/dev/null
fi

log_install_pre 'Docker completions'
docker completion zsh > "$ZSH_CUSTOM/completions/_docker"

# ===============
# Kubernetes tools
# ===============

if ! _has arkade; then
    log_install_pre 'arkade'
    if _is_macos; then
        brew install arkade
    else
        curl -sLS https://get.arkade.dev | sudo sh
    fi
    arkade completion zsh > "$ZSH_CUSTOM/completions/_arkade"
fi
export PATH=$PATH:$HOME/.arkade/bin/

if ! _has kubectl; then
    log_install_pre 'kubectl'
    if _is_macos; then
        brew install kubectl
    else
        arkade get kubectl
    fi
    kubectl completion zsh > "$ZSH_CUSTOM/completions/_kubectl"
fi

if ! _has kubectx; then
    log_install_pre 'kubectx'
    if _is_macos; then
        brew install kubectx
    else
        arkade get kubectx
    fi
fi

if ! _has kubens; then
    log_install_pre 'kubens'
    if _is_macos; then
        # kubens is included in the kubectx brew package
        brew install kubectx
    else
        arkade get kubens
    fi
fi

if ! _has k9s; then
    log_install_pre 'k9s'
    if _is_macos; then
        brew install k9s
    else
        arkade get k9s
    fi
    k9s completion zsh > "$ZSH_CUSTOM/completions/_k9s"
fi

if ! _has helm; then
    log_install_pre 'helm'
    if _is_macos; then
        brew install helm
    else
        arkade get helm
    fi
    helm completion zsh > "$ZSH_CUSTOM/completions/_helm"
fi

if ! _has stern; then
    log_install_pre 'stern'
    if _is_macos; then
        brew install stern
    else
        arkade get stern
    fi
    stern --completion zsh > "$ZSH_CUSTOM/completions/_stern"
fi

if ! _has cmctl; then
    log_install_pre "cmctl - a CLI for cert-manager"
    if _is_macos; then
        brew install cmctl
    else
        arkade get cmctl
    fi
    cmctl completion zsh > "$ZSH_CUSTOM/completions/_cmctl"
fi
