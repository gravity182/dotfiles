# locale
# ------

# you may also need to run:
#  $ sudo locale-gen "en_US.UTF-8"
#  $ sudo dpkg-reconfigure locales
# to see the defined locales, run `locale`
# to see all the available locales, run `locale -a`
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# zsh
# ---

export ZDOTDIR="$HOME"

export ZCONFIG_DIR="$HOME/.config/zsh.d"

# oh-my-zsh
# ---------

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

# PATH
# -------------------

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.claude/local:$PATH"
export PATH="$HOME/.arkade/bin:$PATH"

# Secrets
# -------

# put your secrets in this file; do not commit to git
[[ -s "~/.config/secrets/env.zsh" ]] && source ~/.config/secrets/env.zsh

# Homebrew
# --------

# Configures PATH and FPATH variables
# This enables completions as well; see https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# -------------------
# Java
# -------------------

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

export JAVA_HOME="$SDKMAN_DIR/candidates/java/17.0.15-amzn"

export GRAALVM_HOME="$SDKMAN_DIR/candidates/java/17.0.10-graal"

export GRADLE_USER_HOME="$HOME/.gradle"

# -------------------
# Golang
# -------------------

export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"

# -------------------
# Rust
# -------------------

if [[ -d "$HOMEBREW_PREFIX/opt/rustup/bin" ]]; then
    export PATH="$HOMEBREW_PREFIX/opt/rustup/bin:$PATH"
fi
export PATH="$HOME/.cargo/bin:$PATH"

# -------------------
# JavaScript
# -------------------

export VOLTA_HOME="$HOME/.volta"

if [[ -d "$VOLTA_HOME/bin" ]]; then
    export PATH="$VOLTA_HOME/bin:$PATH"
fi

# Core utils
# ----------

export EDITOR='vim'

export PAGER="less"
# -i - ignore case when searching; works like smart case
# -g - highlight only the current string found by search
# -R - raw output colors; required for bat/delta
# -F - exit immediately if the output size is smaller than the vertical size of the terminal
export LESS="-igRFXM --tabs=4 --mouse"

# should be respected by delta as well
export BAT_THEME="Monokai Extended"

# # colorize man pages; no need to use the colored-man-pages plugin anymore
# # UPD: it works worse than the plugin actually, so I had to disable it
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# # needed to fix colors
# export MANROFFOPT="-c"

# Docker
# ------

export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"

# Testcontainers
# --------------

# https://github.com/testcontainers/testcontainers-java/issues/5034
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock

