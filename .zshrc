#  _____ ____   _   _  ____    ____
# |__  // ___| | | | ||  _ \  / ___|
#   / / \___ \ | |_| || |_) || |
#  / /_  ___) ||  _  ||  _ < | |___
# /____||____/ |_| |_||_| \_\ \____|
#

# Start tmux on every shell login
# 1. if we are not already inside a tmux session,
# 2. and if a terminal is interactive (not automation),
# 3. and if a graphical session is running;
#    remove this condition if you want tmux to start in any login shell, but it might interfere
#    with autostarting X at login,
# 4. then try to attach, if the attachment fails, start a new session.
#
# remember: if server is not running yet,
#   any env vars available at the moment of starting a new session (and a server, consequently)
#   will become server-wide
# in order to pass session-wide vars, use the '-e' option
# i.e. compare `showenv` vs `showenv -g`
if [[ -z "${TMUX}" ]] && [[ -n "$TTY" ]] && [[ -n "$DISPLAY" ]]; then
    exec tmux new-session -A -s $USER >/dev/null 2>&1
fi


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --------------------------------------
# oh-my-zsh settings
# see https://github.com/ohmyzsh/ohmyzsh/wiki/Settings
# --------------------------------------

# this check takes some time during startup
# I'd rather check for updates manually
zstyle ':omz:update' mode disabled
zstyle ':omz:update' frequency 28

# .zcompdump is a cache file used by compinit (completions)
# version is included because the cache file is incompatible between zsh versions
ZSH_COMPDUMP="${ZDOTDIR:-${HOME}}/.zcompdump-${ZSH_VERSION}"
CASE_SENSITIVE=false
DISABLE_MAGIC_FUNCTIONS=false
# disable marking untracked files under VCS as dirty.
# This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY=true
# this breaks colored output in `ls` for some configurations
DISABLE_LS_COLORS=true
ENABLE_CORRECTION=true
# this can cause issues in fzf-tab (https://github.com/Aloxaf/fzf-tab/pull/236#issuecomment-1125102707)
COMPLETION_WAITING_DOTS=false

ZSH_THEME='powerlevel10k/powerlevel10k'

# --------------------------------------
# Plugins
# --------------------------------------

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    vi-mode
    fzf-tab # load fzf-tab early
    colored-man-pages
    zsh-autosuggestions
    fast-syntax-highlighting # much faster than zsh-syntax-highlighting
)

# add this to your /etc/wsl.conf, otherwise syntax highlighting will be very slow
# see https://github.com/zsh-users/zsh-syntax-highlighting/issues/790#issuecomment-1385406603
# [interop]
# appendWindowsPath = false

if [[ "$OSTYPE" == "darwin"* ]]; then
    plugins+=(gnu-utils)
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
fi

# I don't need any aliases
zstyle ':omz:plugins:*' aliases no
# you can allow specific plugins though
# zstyle ':omz:plugins:gnu-utils' aliases yes

# --------------------------------------
# Helper functions
# --------------------------------------

# might want to convert it to the autoload style to reduce startup time
# fpath+="$ZCONFIG_DIR/functions"
# autoload ...
source "$ZCONFIG_DIR/functions/helpers.zsh"

# --------------------
# Completions (fpath)
# --------------------

# brew shell completion
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
if _is_osx; then
    _has brew && [[ -d $(brew --prefix)/share/zsh/site-functions ]] && fpath+="$(brew --prefix)/share/zsh/site-functions"
fi

# this must be added to fpath before loading omz
# adding it as a plugin is correct, but not very optimal
# see https://github.com/zsh-users/zsh-completions/issues/603
fpath+="$ZSH_CUSTOM/plugins/zsh-completions/src"

# if you want to navigate through completions in vi-like style (hjkl)
# not needed when fzf-tab installed
#
# zmodload zsh/complist
# bindkey -M menuselect 'h' vi-backward-char
# bindkey -M menuselect 'k' vi-up-line-or-history
# bindkey -M menuselect 'l' vi-forward-char
# bindkey -M menuselect 'j' vi-down-line-or-history


# ======================================
# Load oh-my-zsh (boot stage)
# ======================================

# all completions must be added to the fpath before loading oh-my-zsh, which calls compinit

source $ZSH/oh-my-zsh.sh


# ======================================
# Zsh tuning
# ======================================

# uncomment the next line to profile your boot script; execute `zprof` to see data
# zmodload zsh/zprof

# a helper function to measure the startup time
timezsh() {
    shell=${1-$SHELL}
    for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

# this is the best method to measure the startup time
# see https://www.reddit.com/r/zsh/comments/1bqtb7m/comment/kx5x33l
tracezsh() {
    ( exec -l zsh --sourcetrace 2>&1 ) | ts -i '%.s'
}

# uncomment the next lines to measure startup time of each plugin
# for plugin ($plugins); do
#   timer=$(($(date +%s%N)/1000000))
#   if [ -f $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh ]; then
#     source $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh
#   elif [ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]; then
#     source $ZSH/plugins/$plugin/$plugin.plugin.zsh
#   fi
#   now=$(($(date +%s%N)/1000000))
#   elapsed=$(($now-$timer))
#   echo $elapsed"ms"":" $plugin
# done


# ======================================
# User configuration (post-boot stage)
# ======================================

# -------------------
# PATH
# -------------------

if [[ -d "$HOME/.local/bin" ]]; then
    path=("$HOME/.local/bin" $path)
fi

if [[ -d "$HOME/.arkade/bin" ]]; then
    path+=("$HOME/.arkade/bin/")
fi

# -----------------
# Options
# -----------------

unsetopt autocd

# only correct commands but not its arguments
setopt correct
unsetopt correct_all

# you may also need to run:
#  $ sudo locale-gen "en_US.UTF-8"
#  $ sudo dpkg-reconfigure locales
# to see the defined locales, run `locale`
# to see all the available locales, run `locale -a`
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
LC_CTYPE=en_US.UTF-8

# -----------------------
# History
# -----------------------

# When the history file is re-written, write out a copy of the file named $HISTFILE.new
# and then rename it over the old one (atomic rename)
setopt HIST_SAVE_BY_COPY
# ignore duplicate entries
setopt HISTIGNOREDUPS
# prevents the current line from being saved if it begins with a space
setopt HISTIGNORESPACE
# When writing out the history file, by default zsh uses ad-hoc file locking to avoid known problems with
# locking on some operating systems.
# With this option locking is done by means of the system’s fcntl call, where this method is available.
# On recent operating systems this may provide better performance,
# in particular avoiding history corruption when files are stored on NFS
setopt HIST_FCNTL_LOCK

# history size
HISTSIZE=10000
SAVEHIST=10000

# -----------------------
# vi mode
# -----------------------

# the vi-mode plugin already calls `bindkey -v`, but anyway
bindkey -v

# switch modes faster (time in milliseconds)
# vi mode feels much more responsive after this
export KEYTIMEOUT=1

# defaults (vi-mode plugin)
VI_MODE_CURSOR_NORMAL=2
VI_MODE_CURSOR_VISUAL=6
VI_MODE_CURSOR_INSERT=6
VI_MODE_CURSOR_OPPEND=0

# this remaps `vv` to `E` (but overrides `visual-mode`)
# unfortunately `vv` doesn't work due to low keytimeout
bindkey -M vicmd 'E' edit-command-line

# -----------------------
# Completions (zstyle)
# -----------------------

# zstyle pattern:
# :completion:<function>:<completer>:<command>:<argument>:<tag>

# include dotfiles in completion
_comp_options+=(globdots)

# don't expand aliases before completion has finished
# this option might prevent completions from working with aliases
# see https://unix.stackexchange.com/a/583743/346664
# e.g. try the following with this option on:
#   $ alias g='git'
#   $ g<Tab>
# the result is alias won't show completions
unsetopt complete_aliases

# bindkey '^i' expand-or-complete-prefix

# set descriptions format to enable group support
# fzf-tab will group the results by group description
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# matches case insensitive for lowercase search (smart-case)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending
# sort files alphabetically (dummy value)
# zstyle ':completion:*' file-sort dummyvalue
# TODO sorting doesn't work for some reason
zstyle ':completion:*' file-sort modification
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
zstyle ':completion:*' squeeze-slashes true
# autocomplete options for cd instead of dirstack
zstyle ':completion:*' complete-options true
zstyle ':completion:*' keep-prefix true

# respect FZF_DEFAULT_OPTS
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-min-height 18
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' continuous-trigger '/'

# for some reason this ctrl-space binding from the default opts isn't honored
# add it one more time
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-space:toggle+down'

zstyle ':fzf-tab:complete:cd:*'                       fzf-preview 'tree -L 2 -C $realpath'
zstyle ':fzf-tab:complete:(ssh|scp|sftp|rsh|rsync):*' fzf-preview 'dig $word'
zstyle ':fzf-tab:complete:systemctl-*:*'              fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# allow multi-selection by default
zstyle ':fzf-tab:complete:*' fzf-flags '--multi'

zstyle ':completion:*:ssh:argument-1:'                  tag-order  hosts users
zstyle ':completion:*:scp:argument-rest:'               tag-order  hosts files users
zstyle ':completion:*:(ssh|scp|sftp|rsh|rsync):*:hosts' hosts

# -----------------------
# zoxide
# -----------------------

# --cmd cd will replace the `cd` command
# that is, cd=z, cdi=zi
eval "$(zoxide init zsh --cmd cd)"

# -----------------
# SSH keys
# -----------------

# run ssh-agent if not already running
if [[ -z "$SSH_AGENT_PID" ]]; then
    eval "$(ssh-agent -s)" &>/dev/null
fi


# ===============
# EXPORTS START
# To see the full list of active exports, run `export`
# To search, run `exf`
# ===============

# -------------------
# Core userland utils
# -------------------

export EDITOR='vim'

export PAGER="less"
# -i - ignore case when searching; works like smart case
# -g - highlight only the current string found by search
# -R - raw output colors; required for bat/delta
# -F - exit immediately if the output size is smaller than the vertical size of the terminal
export LESS="-igRFXM --tabs=4 --mouse"

# should be respected by delta diff as well
export BAT_THEME="Monokai Extended"

# colorize man pages; no need to use the colored-man-pages plugin anymore
# UPD: it works worse than the plugin actually, so I had to disable it
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# # needed to fix colors
# export MANROFFOPT="-c"

# -------------------
# Java exports
# -------------------

# select the default java version via `sdk default java <ver>`
export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
export GRAALVM_HOME="$HOME/.sdkman/candidates/java/17.0.10-graal"
export GRADLE_USER_HOME="$HOME/.gradle"

# -------------------
# JavaScript exports
# -------------------

export VOLTA_HOME="$HOME/.volta"

if [[ -d "$VOLTA_HOME/bin" ]]; then
    path+="$VOLTA_HOME/bin"
fi

# -------------------
# Unset exports
# -------------------

#unset

# ===============
# EXPORTS END
# ===============


# ===============
# ALIASES START
# ---
# To see the full list of active aliases, run `alias`
# To search for a specific alias, run `alf`
#
# Remember that aliases are expanded when the function definition is parsed,
# so usually you want to define aliases before functions
# ===============

# -------------------
# Configs
# -------------------

alias zshconfig="$EDITOR ~/.zshrc; zshreload"
alias zshcfg='zshconfig'
alias zshreload='exec zsh'
alias zshrld='zshreload'

alias tmuxconfig="$EDITOR ~/.tmux.conf; tmux source ~/.tmux.conf"
alias tmuxcfg="tmuxconfig"
alias tconfig="tmuxconfig"
alias tcfg='tmuxconfig'

alias sshconfig="$EDITOR ~/.ssh/config"
alias sshcfg='sshconfig'

export VIM_HOME="$HOME/.vim"
alias vimconfig="vim "$VIM_HOME/my_configs.vim""
alias vimcfg='vimconfig'

alias ignoreconfig="$EDITOR ~/.ignore"
alias ignorecfg='ignoreconfig'

# ---------------------
# yadm (dotfiles sync)
# ---------------------

function .dotsync() {
    yadm pull
    if [[ -z "$(yadm status --porcelain)" ]]; then
        echo "Everything up-to-date"
        return 0
    fi
    yadm add -u
    yadm commit --reedit-message=HEAD
    yadm push
}

alias sysyadm="sudo yadm --yadm-dir /etc/yadm --yadm-data /etc/yadm/data"

function .dotsync-sys() {
    sysyadm pull
    if [[ -z "$(sysyadm status --porcelain)" ]]; then
        echo "Everything up-to-date (sys)"
        return 0
    fi
    sysyadm add -u
    sysyadm commit --reedit-message=HEAD
    sysyadm push
}

# -------------------
# Core utils
# -------------------

alias hs='history'

if _has fd; then
    alias fd='fd --hidden --no-ignore-vcs --follow'

    alias fdf='fd -t f --strip-cwd-prefix --hidden --no-ignore-vcs --follow 2>/dev/null'
    alias fdd='fd -t d --strip-cwd-prefix --hidden --no-ignore-vcs --follow 2>/dev/null'
    alias fdd1='fd -t d -d 1 --strip-cwd-prefix --hidden --no-ignore-vcs --follow 2>/dev/null'
else
    alias fdf='find . -type f -iname'
    alias fdd='find . -type d -iname'
fi

function vimf() {
    local file=$(fzf)
    if [[ -z "$file" ]]; then
        return 0
    fi
    vim -o "$file"
}
alias vf='vimf'

if _is_linux; then
    alias df='df -H -T'
elif _is_osx; then
    alias df='df -H -Y -I -l 2>/dev/null'
fi

alias bat='bat --style=auto'

# colorize help pages
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# use bat by default
alias cat='bat'

# -r, -R, --recursive
#   remove directories and their contents recursively
alias rm='rm -rf'
# -i
#   prompt before every removal
alias rmi='rm -i'

# -R, -r, --recursive
#   copy directories recursively
alias cp='nocorrect cp -R'

# -p, --parents
#   no error if existing, make parent directories as needed
# -v, --verbose
#   print a message for each created directory
alias mkdir='nocorrect mkdir -pv'
function mkcd() {
    mkdir "$1"
    builtin cd "$1"
}

alias whereami='pwd'

alias eza='eza --color=auto --classify=auto --icons=never'

# use eza instead of ls
alias ls='eza'
alias l='eza --git-ignore'
alias ll='eza --all --header --long'
alias llm='eza --all --header --long --sort=modified'
alias li='eza --all --header --long --inode'
alias la='eza -lbhHigUmuSa'
# lits dot files only
alias ldot='eza -ld .*'

alias tree='eza --tree'
alias tree1='tree --level 1'
alias tree2='tree --level 2'

if _has rg; then
    alias rg='rg --smart-case --hidden --no-ignore-vcs'
fi

alias tarc='tar -czvf'

# Tar e[x]tract
#   Usage: tarx archive.tar.gz [file1 file2..] [-C/--directory=DIR]
# Note: you don't need to specify a compression method when extracting or listing an archive
# Note: use 'extract' plugin if tar isn't enough (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/extract). Notably, this plugins supports rar and zip archives
#
alias tarx='tar -xvf'

# Tar list files inside an archive
alias tarls='tar -tvf'

# shows job's PID
# execute `bg %n` to continue a suspended job and run it in the background
# execute `fg %n` switch a job running in the background into the foreground (it'll also automatically continue the job)
# execute `kill %n` or `kill <pid>` to kill the job
alias jobs='jobs -l'

# ps aliases
# note that ps options vary greatly depending on the OS
if _is_linux; then
    # -e
    #   select all processes
    # -o format
    #   Specify user-defined format. See the 'STANDARD FORMAT SPECIFIERS' section.
    # --sort spec
    #   Specify sorting order.
    #   The "+" is optional since default direction is increasing numerical or lexicographic order.
    #   The "-" reverses direction only on the key it precedes.
    alias ps='command ps -eo user,pid,ppid,tname,stat,start_time,bsdtime,command --forest --sort -user,+pid'
    # includes process group id and session id
    alias ps_job='command ps -eo user,pid,ppid,pgid,sid,tname,stat,start_time,bsdtime,command --forest --sort -user,+pid'
    # includes memory resources
    alias ps_resources='command ps -eo user,pid,ppid,pcpu,pmem,vsz,rss,tname,stat,start_time,bsdtime,command --forest --sort -user,+pid,+vsz,+rss'
elif _is_osx; then
    # -e
    #   Display information about other users' processes, including those without controlling terminals
    #   This is identical to -ax
    # -o format
    # BSD's ps doesn't support the tree view
    alias ps='command ps -eo user,pid,ppid,tty,stat,start,cputime,command'
    alias ps_job='command ps -eo user,pid,ppid,pgid,sess,tty,stat,start,cputime,command'
    alias ps_resources='command ps -eo user,pid,ppid,pgid,pcpu,pmem,vsz,rss,tty,stat,start,cputime,command'
fi
function psa() {
    ps | rg --color=always "$1|PID" | rg -v "rg"
}
alias htop='htop --tree'

alias killall='command killall -v'

alias pgrep='command pgrep -a'
alias pkill='command pkill -e'

# VIM FTW
alias :q='exit'
alias :wq='exit'

# -------------------
# SSH
# -------------------

# Opens an SSH tunnel
# $1 - local port
# $2 - remote port
# $3 - host or host alias
function ssh_tun_open() {
    if [[ -z $1 || -z $2 || -z $3 ]]; then
        echo 'Please provide a local port, a remote port, and a host'
        return 1
    fi
    autossh -M 0 -f -T -N -L '127.0.0.1:'"$1"':localhost:'"$2" "$3"
    sleep 1
    echo "SSH tunnel opened for '$3': local:$1->remote:$2"
    if _has firefox; then
        scheme=$(curl -X GET --silent --output /dev/null --write-out "%{scheme}" 'localhost:'"$1")
        if [[ "$scheme" =~ "HTTP*" ]]; then
            eval $(firefox 'localhost:'"$1") &
        fi
    fi
}

# Closes all opened SSH tunnels for the specified host
# $1 - host or host alias
function ssh_tun_close() {
    if [[ -z $1 ]]; then
        echo 'Please provide a host'
        return 1
    fi
    pkill -e -f "autossh.*localhost.*$1"
}

# Closes all opened SSH tunnels
function ssh_tun_close_all() {
    pkill -e "autossh"
}

# ------------------------
# Observability
# ------------------------

alias lsof_inet="lsof -i -P -n"
alias lsof_inet_listen="lsof -i -P -n | grep LISTEN"

# ------------------------
# curl
# ------------------------

# follow redirects by default
alias curl="curl -L"

# by default curl writes to stdout
# download file with the same name as a remote (only filename part is used, the path is cut off)
alias curl_dl="curl -O"

# -I - show document info only
alias curl_info="curl -LI"
# this command is better suited for scripts:
# -s - silent mode
# -S - show errors even when -s is used
# -f - fail silently (no output at all) on server errors.
#      This is mostly done to better enable scripts etc to better deal with failed attempts.
#      In normal cases when an HTTP server fails to deliver a document, it returns an HTML document
#      stating so (which often also describes why and more).
#      This flag will prevent curl from outputting that and return error 22
# -L - follow redirects
alias curl_script="curl -sSfL"

# ------------------------
# wget
# ------------------------

alias wget_stdout="wget -O-"

# ------------------------
# HTTP/DNS requests
# ------------------------

function curl_ping() {
    if [[ -z "$1" ]]; then
        echo "Please provide a host to ping"
        return 1
    fi

    local curl_ping_format="\
    time_namelookup:    %{time_namelookup}
    time_connect:       %{time_connect}
    time_appconnect:    %{time_appconnect}
    time_pretransfer:   %{time_pretransfer}
    time_redirect:      %{time_redirect}
    time_starttransfer: %{time_starttransfer}
    --------------------
    time_total:         %{time_total}\n"
    curl -w "$curl_ping_format" -o /dev/null -s "$1"
}

function cheat() {
    if [[ -z "$1" ]]; then
        echo 'Please provide a command to look up!'
        return 1
    fi
    curl "cheat.sh/$1"
}

whatismyip() {
    dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"'
}
alias whatsmyip='whatismyip'
whatip() {
    if [[ -z "$1" ]]; then
        echo 'Please provide an IP address to look up!'
        return 1
    fi
    curl -s "https://ipinfo.io/$1/json" | jq
}

# -------------------
# FZF-powered aliases
# -------------------

# Note that FZF has its own, very useful keybindings:
# CTRL-T: find a file
# CTRL-R: history search
# ALT-C (CTRL-E): find a dir and cd into it

# aliases
alias alf='alias | fzf'
alias af='alf'

# environment variables
alias exf='export | fzf'
alias envf='env | fzf'

# file/dir explorer powered by fzf + fd
#  CTRL-D to display directories | CTRL-F to display files
#  TAB to multi-select
#  CTRL-A to select all | CTRL-X to deselect all
#  CTRL-/ to toggle preview
#  ENTER to edit | CTRL-R to interactively delete
function ff() {
    local selection=$(fd -t f -d 1 --hidden --no-ignore-vcs --follow --color never 2>/dev/null | fzf --multi \
    --height=80% \
    --color header:italic \
    --header 'Press CTRL-F to display files | CTRL-D to display dirs
Press <CR> to edit file or cd into dir
Press CTRL-/ to toggle the preview window' \
    --preview='bat --style numbers,changes --color=always --line-range=:500 {}' \
    --preview-window='45%,border-sharp' \
    --prompt='Files ∷ ' \
    --bind='ctrl-r:execute(rm -ri {+})' \
    --bind='ctrl-/:toggle-preview' \
    --bind='ctrl-d:change-prompt(Dirs ∷ )' \
    --bind='ctrl-d:+reload(fd -t d -d 1 --hidden --no-ignore-vcs --follow --color never 2>/dev/null)' \
    --bind='ctrl-d:+change-preview(tree -L 1 -C {})' \
    --bind='ctrl-d:+refresh-preview' \
    --bind='ctrl-f:change-prompt(Files ∷ )' \
    --bind='ctrl-f:+reload(fd -t f -d 1 --hidden --no-ignore-vcs --follow --color never 2>/dev/null)' \
    --bind='ctrl-f:+change-preview(bat --style numbers --color=always --line-range=:500 {})' \
    --bind='ctrl-f:+refresh-preview' \
    --bind='ctrl-a:select-all' \
    --bind='ctrl-x:deselect-all')

    if [ -z "$selection" ]; then
        return 0
    elif [ -d "$selection" ]; then
        builtin cd "$selection"
    else
        eval "$EDITOR $selection"
    fi
}

# search for a process using fzf
function procf() {
    local pid=$(ps | fzf --query="$1" --print0 | awk '{print $2}')
    if [[ -n "$pid" ]]; then
        echo "The process: $pid"
    else
        echo 'No processes found'
    fi
}

# search for a man page
function manf() {
    local preselected_section="$1"
    local manpage=$(apropos -s ${preselected_section:-'1:2:4:5:7:9'} . 2>/dev/null | sort -u | fzf -d '-' --nth 1 --print0)
    if [[ -z $manpage ]]; then
        return 0
    fi

    local page=$(echo $manpage | awk -F'[,()]' '{print $1}')
    local section=$(echo $manpage | awk -F'[,()]' '{print $2}')
    man $section ${page%% }
}
function manf2() {
    local preselected_section="$1"
    local manpage=$(apropos -s ${preselected_section:-'1:2:4:5:7:9'} . 2>/dev/null | sort -u | fzf --print0)
    if [[ -z $manpage ]]; then
        return 0
    fi

    local page=$(echo $manpage | awk -F'[,()]' '{print $1}')
    local section=$(echo $manpage | awk -F'[,()]' '{print $2}')
    man $section ${page%% }
}

# -------------------
# Git
# ---
# Note: aliases are set in .gitconfig
# -------------------

alias gitcfg="$EDITOR ~/.gitconfig"
alias gitcfg_ignore="$EDITOR ~/.gitignore; git config --global core.excludesfile ~/.gitignore"

# -------------------
# Misc aliases
# -------------------

alias ai='aichat'

# apply the provided functions ($2...) to all files or dirs found by the provided glob ($1)
# all functions must accept exactly one argument, which would be the path of a found file/dir
# usage:
#   run_on_files '*.webp' 'ffmpeg_img2jpg' 'rm'
function run_on_dirs() {
    local fd_regex="$1"
    local fd_func="$2"' "$1"'
    for func in "${@:3}"
    do
        fd_func+=";$func"' "$1"'
    done
    fd --type directory --max-depth 1 --glob "$fd_regex" -x $SHELL -i -c "$fd_func" $SHELL {}
}
function run_on_files() {
    local fd_regex="$1"
    local fd_func="$2"' "$1"'
    for func in "${@:3}"
    do
        fd_func+=";$func"' "$1"'
    done
    fd --type file --glob "$fd_regex" -x $SHELL -i -c "$fd_func" $SHELL {}
}
alias execute_on_dirs='run_on_dirs'
alias execute_on_files='run_on_files'

# or just:
#   `fd -t f -g "*.mohidden" -x mv {} ../`
# where {} is a file found by fd search
# the command above moves all files one dir level up
#
# another example: file conversion with successive deletion:
#   `fd -t f -g ".webp" -x ffmpeg_img2jpg {} && rm {}`
# the command above converts all .webp files to .jpg format and then deletes them

# view raw keycodes that terminal sends
alias monitor_keycode='sed -n l'

# -------------------
# Unset aliases
# -------------------

#unalias

# ===============
# ALIASES END
# ===============


# =====================
# PLUGINS CONFIG START
# =====================

# -------------------
# AWS
# -------------------

SHOW_AWS_PROMPT=false

# -------------------
# VI-MODE
# -------------------

VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

# cursor style
VI_MODE_CURSOR_NORMAL=2
VI_MODE_CURSOR_VISUAL=2
VI_MODE_CURSOR_INSERT=6
VI_MODE_CURSOR_OPPEND=0

# p10k supports mode display out of the box
# MODE_INDICATOR="%F{105}<<<%f"
# RPROMPT="\$(vi_mode_prompt_info)$RPROMPT"

# -------------------
# zsh-autosuggestions
# -------------------

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# tune this value to your liking
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ctrl + arrow key will accept a suggestion partially
bindkey '^[[1;5C' vi-forward-word
bindkey '^[[1;5D' vi-backward-word
# ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()
# ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(forward-char end-of-line vi-forward-char vi-forward-word forward-word vi-end-of-line vi-add-eol)

# =====================
# PLUGINS CONFIG END
# =====================


# ===============
# MISCELLANEOUS
# ===============

# sdkman
# ------

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# fzf
# ---

# fzf shell integration
# to enable on macOS + brew, execute /opt/homebrew/opt/fzf/install;
# to enable on Ubuntu (provided fzf has been installed directly from the git repo), execute ~/.fzf/install;
# this will generate the ~/.fzf.zsh file which should be sourced here
source ~/.fzf.zsh

# Specify the default command that fzf shall execute on empty stdin
export FZF_DEFAULT_COMMAND='fd -t f --strip-cwd-prefix --hidden --no-ignore-vcs --follow 2>/dev/null'

# see https://github.com/junegunn/fzf#key-bindings-for-command-line
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd -t d -d 1 --strip-cwd-prefix --hidden --no-ignore-vcs --follow 2>/dev/null'

# these default options will be used everytime you call fzf
FZF_MIN_HEIGHT="40%"
export FZF_DEFAULT_OPTS="--height $FZF_MIN_HEIGHT
  --border horizontal
  --layout reverse
  --info default
  --separator ''
  --prompt '∷ '
  --pointer '>'
  --marker '>'
  --bind 'tab:down'
  --bind 'shift-tab:up'
  --bind 'ctrl-space:toggle+down'
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:accept'
  --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up'
  "

# these options overwrite the default ones above
export FZF_BINDING_OPTS="--border rounded
  --layout default
  --info inline-right
  --color header:italic
  --separator '─'
  "
export FZF_CTRL_T_OPTS="$FZF_BINDING_OPTS
  --preview 'bat --color=always --style=numbers --line-range=:500 {}'
  --bind 'ctrl-/:change-preview-window(hidden|)'
  "
export FZF_ALT_C_OPTS="$FZF_BINDING_OPTS
  --preview 'tree -L 2 -C {}'
  --bind 'ctrl-/:change-preview-window(hidden|)'
  "
export FZF_CTRL_R_OPTS="$FZF_BINDING_OPTS
  --preview 'echo {}'
  --preview-window down:5:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  "

# map Ctrl-E to the cd/dir search (the same as Alt-C)
zle     -N              fzf-cd-widget
bindkey -M emacs '\C-e' fzf-cd-widget
bindkey -M vicmd '\C-e' fzf-cd-widget
bindkey -M viins '\C-e' fzf-cd-widget

# type **<tab> to complete the sentence
# see https://github.com/junegunn/fzf?tab=readme-ov-file#fuzzy-completion-for-bash-and-zsh
export FZF_COMPLETION_TRIGGER='**'
export FZF_COMPLETION_OPTS="--bind 'ctrl-/:change-preview-window(hidden|)'"

# Use fd to generate an input for path completion
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
function _fzf_compgen_path() {
    fd --hidden --no-ignore-vcs --follow . "$1" 2>/dev/null
}

# Use fd to generate an input for dir completion
function _fzf_compgen_dir() {
    fd -t d --hidden --no-ignore-vcs --follow . "$1" 2>/dev/null
}

# Advanced customization of fzf options via _fzf_comprun function
#
# Note these completions are not really useful as it's a different mechanism
# compared to the standard zsh completions which support more commands
#
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
function _fzf_comprun() {
    local command=$1
    shift

    # add custom commands to leverage from autocompletion here
    # note that some commands already use autocompletion (like cd) and don't require an input
    # on the other hand, tree is a custom command which requires input
    case "$command" in
        cd)           fzf --preview 'tree -L 2 -C {} | head -200' "$@" ;;
        tree)         fzf --preview 'tree -L 2 -C {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo \$'{}"            "$@" ;;
        ssh)          fzf --preview 'dig {}'                      "$@" ;;
        *)            fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' "$@" ;;
    esac
}

alias fzf_regex_help="echo \"\
sbtrkt      fuzzy-match                     Items that match sbtrkt
'wild       exact-match (quoted)            Items that include wild
^music      prefix-exact-match              Items that start with music
.mp2$       suffix-exact-match              Items that end with .mp3
!fire       inverse-exact-match             Items that do not include fire
!^music     inverse-prefix-exact-match      Items that do not start with music
!.mp2$      inverse-suffix-exact-match      Items that do not end with .mp3\"
"
# rust regex help (used by fzf, rg, fd)
# see https://docs.rs/regex/1.10.3/regex/#syntax
alias rust_regex_help="echo \"\
.          any character except new line
[0-9]      any ASCII digit
[xyz]      A character class matching either x, y or z
[^xyz]     A character class matching any character except x, y and z
[a-z]      A character class matching any character in range a-z
x*         zero or more of x
x+         one or more of x
x?         zero or one of x
x{n}       exactly n x
^          the beginning of a haystack
$          the end of a haystack\"
"
alias fd_regex_help=rust_regex_help
alias rg_regex_help=rust_regex_help

# AWS CLI
# -------

if _has aws; then
    # prefill the path to aws_completer for faster startup
    # check the path via `which aws_completer`
    complete -C '/usr/local/bin/aws_completer' aws
fi

# =====================
# Source other configs
# =====================

find $ZCONFIG_DIR/source -type f | sort | while read -r file; do
    source "$file"
done

# =============
# Final config
# ---
# Dependent on the source files above or overwrites
# =============

# Normalize `open` across Linux, macOS, and Windows
if ! _is_osx; then
    if _is_wsl; then
        alias open='explorer.exe'
    else
        alias open='xdg-open'
    fi
fi
function open() {
    if [[ -z "$1" ]]; then
        open .
    else
        open "$1"
    fi
}
alias open='open'


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh directly
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

