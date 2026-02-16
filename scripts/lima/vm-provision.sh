#!/usr/bin/env bash
set -euo pipefail

# --- System packages ---
apt_cache="/var/cache/apt/pkgcache.bin"
cache_age=$(( $(date +%s) - $(stat -c %Y "$apt_cache" 2>/dev/null || echo 0) ))
if [ "$cache_age" -gt 86400 ]; then
  echo "==> Updating system packages..."
  sudo apt-get update
  sudo apt-get upgrade -y
else
  echo "==> Apt cache is fresh, skipping update/upgrade."
fi
echo "==> Installing system packages..."
sudo apt-get install -y \
  vim screen htop iotop sysstat smem ccze jq \
  build-essential ca-certificates pkg-config libssl-dev \
  curl wget unzip


# --- mise (dev tool manager) ---
export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise &>/dev/null; then
  echo "==> Installing mise..."
  curl https://mise.run | sh
else
  echo "==> mise already installed, skipping."
fi

# --- Dev tools via mise ---
if ! mise x -- node --version &>/dev/null; then
  echo "==> Installing Node.js via mise..."
  mise use -g node@lts
else
  echo "==> Node.js already installed, skipping."
fi

if ! mise x -- go version &>/dev/null; then
  echo "==> Installing Go via mise..."
  mise use -g go@latest
else
  echo "==> Go already installed, skipping."
fi

if ! mise x -- rustc --version &>/dev/null; then
  echo "==> Installing Rust via mise..."
  mise use -g rust@latest
else
  echo "==> Rust already installed, skipping."
fi

if ! mise x -- uv --version &>/dev/null; then
  echo "==> Installing uv via mise..."
  mise use -g uv@latest
else
  echo "==> uv already installed, skipping."
fi

eval "$(mise activate bash)"

# --- Docker ---
if ! command -v docker &>/dev/null; then
  echo "==> Installing Docker..."
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
  sudo usermod -aG docker "$USER"
else
  echo "==> Docker already installed, skipping."
fi

# --- GitHub CLI ---
if ! command -v gh &>/dev/null; then
  echo "==> Installing GitHub CLI..."
  (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
else
  echo "==> GitHub CLI already installed, skipping."
fi

# --- Claude Code ---
if ! command -v claude &>/dev/null; then
  echo "==> Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "==> Claude Code already installed, skipping."
fi

# --- Codex ---
if ! command -v codex &>/dev/null; then
  echo "==> Installing Codex..."
  npm i -g @openai/codex
else
  echo "==> Codex already installed, skipping."
fi

# --- Kubernetes tools ---
for k8s_tool in kubectl helm k9s kubectx kubens stern kustomize; do
  if ! command -v "$k8s_tool" &>/dev/null; then
    echo "==> Installing ${k8s_tool} via mise..."
    mise use -g "${k8s_tool}@latest"
  else
    echo "==> ${k8s_tool} already installed, skipping."
  fi
done


# --- Shell config (separate file, sourced from .bashrc) ---
cat > ~/.bashrc.vm <<'BASHRC'
# Source per-VM secrets and env vars (not committed to git)
# On the host: ~/VM-Shared/lima-<name>/.env (e.g. ~/VM-Shared/lima-dev/.env)
[ -f ~/Shared/$(hostname)/.env ] && . ~/Shared/$(hostname)/.env
eval "$($HOME/.local/bin/mise activate bash)"

export HISTSIZE=262144
export HISTFILESIZE=262144
export EDITOR="vim"

alias ll='ls -alh'
alias htop="htop --sort-key=PERCENT_CPU"
alias sr="screen -d -r"
alias gs='git status -sb'
alias gd="git diff"
alias gl='git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
alias claude="claude --dangerously-skip-permissions"
alias codex="codex --dangerously-bypass-approvals-and-sandbox"
BASHRC

grep -q 'bashrc.vm' ~/.bashrc || echo '[ -f ~/.bashrc.vm ] && . ~/.bashrc.vm' >> ~/.bashrc

# Ensure login bash shells load both ~/.profile and ~/.bashrc.
# This makes aliases from ~/.bashrc.vm available in SSH/limactl shell sessions.
if ! grep -q 'VM-BASH-PROFILE-GLUE' ~/.bash_profile 2>/dev/null; then
  cat >> ~/.bash_profile <<'BASH_PROFILE'
# VM-BASH-PROFILE-GLUE
[ -f ~/.profile ] && . ~/.profile
[ -f ~/.bashrc ] && . ~/.bashrc
BASH_PROFILE
fi

echo ""
echo "==> Provisioning complete!"
echo "    Node: $(mise x -- node --version)"
echo "    Go:   $(mise x -- go version)"
echo "    Rust: $(mise x -- rustc --version)"
echo "    gh:   $(gh --version | head -1)"
