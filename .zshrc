#  _____ ____   _   _  ____    ____
# |__  // ___| | | | ||  _ \  / ___|
#   / / \___ \ | |_| || |_) || |
#  / /_  ___) ||  _  ||  _ < | |___
# /____||____/ |_| |_||_| \_\ \____|
#

# Start tmux on every shell login
# 1. if not already inside a tmux session,
# 2. and if a terminal is interactive (not automation),
# 3. and if a graphical session is running;
#    remove this condition if you want tmux to start in any login shell, but it might interfere
#    with autostarting X at login;
#    on MacOS this check is not needed,
# 4. then try to attach, if the attachment fails, start a new session.
#
# remember: if server is not running yet,
#   any env vars available at the moment of starting a new session (and a server, consequently)
#   will become server-wide
# in order to pass session-wide vars, use the '-e' option
# i.e. compare `showenv` vs `showenv -g`
#
# Notes on the iTerm2 tmux integration:
# `tmux -CC` initiates a 'control client' session
# It makes tmux the backend, sending raw data to iTerm2
# iTerm2 acts as the frontend, enabling native window/session handling and rendering
# Moreover, the tmux keybindings (including the prefix) won't work anymore,
# since everything is handled natively by iTerm2 in this regard.
# See https://gitlab.com/gnachman/iterm2/-/issues/9970#note_717936845
#
# Set to 1 to disable auto-launching tmux
TMUX_DISABLE=1
# Set to `1` to enable iTerm2 tmux integration
ITERM_ENABLE_TMUX_INTEGRATION=0
if [[ ${TMUX_DISABLE} != 1 ]] && [[ -z "${TMUX}" ]] && [[ -n "$TTY" ]] && ([[ "$OSTYPE" == "darwin"* ]] || [[ -n "$DISPLAY" ]]); then
    if [[ $ITERM_ENABLE_TMUX_INTEGRATION -eq 1 ]]; then
        exec tmux -CC new-session -A -s $USER >/dev/null 2>&1
    else
        exec tmux new-session -A -s $USER >/dev/null 2>&1
    fi
fi

# Set to 1 to disable auto-launching zellij
ZELLIJ_DISABLE=1
# Checks:
# 1. If auto-launching is not disabled.
# 2. If NOT already inside a zellij session ($ZELLIJ is not set).
# 3. If running in an interactive terminal (TTY is set).
# 4. If on macOS or in a graphical environment (DISPLAY is set).
if [[ ${ZELLIJ_DISABLE} != 1 ]] && [[ -z "$ZELLIJ" ]] && [[ -n "$TTY" ]] && ([[ "$OSTYPE" == "darwin"* ]] || [[ -n "$DISPLAY" ]]); then
    exec zellij attach --create $USER
fi

# https://www.reddit.com/r/zellij/comments/10skez0/does_zellij_support_changing_tabs_name_according/
zellij_tab_name_update() {
  if [[ -n $ZELLIJ ]]; then
    tab_name=''
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        tab_name+=$(basename "$(git rev-parse --show-toplevel)")/
        tab_name+=$(git rev-parse --show-prefix)
        tab_name=${tab_name%/}
    else
        tab_name=$PWD
            if [[ $tab_name == $HOME ]]; then
            tab_name="~"
             else
            tab_name=${tab_name##*/}
             fi
    fi
    command nohup zellij action rename-tab $tab_name >/dev/null 2>&1
  fi
}

zellij_tab_name_update
chpwd_functions+=(zellij_tab_name_update)

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Helper functions
# might want to convert it to the autoload style to reduce startup time
source "$ZCONFIG_DIR/functions/helpers.zsh"

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

if [[ "$OSTYPE" == "darwin"* ]]; then
    plugins+=(gnu-utils)
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
fi

# I don't need any aliases
zstyle ':omz:plugins:*' aliases no
# you can allow specific plugins though
# zstyle ':omz:plugins:gnu-utils' aliases yes

# --------------------
# Completions (fpath)
# --------------------

# brew shell completion

# this must be added to fpath before loading omz
#
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

# all completions must be added to the fpath before loading oh-my-zsh, which invokes compinit

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

# this is the best method to measure the startup time (by romkatv)
# see https://www.reddit.com/r/zsh/comments/1bqtb7m/comment/kx5x33l
tracezsh() {
    ( exec -l zsh --sourcetrace 2>&1 ) | ts -i '%.s'
}
# you MUST hit Ctrl-D to exit the subshell for sort to work
tracezsh_sorted() {
    ( exec -l zsh --sourcetrace 2>&1 ) | ts -i '%.s' | sort -nr -k1,1
}

# another method to measure startip time
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

# -----------------
# Options
# -----------------

unsetopt autocd

# only correct commands but not its arguments
setopt correct
unsetopt correct_all

# -----------------------
# History
# -----------------------

# The EXTENDED_HISTORY changes the format of .zsh_history to record when (in seconds from the Unix epoch) a command was executed and (with INC_APPEND_HISTORY_TIME) how long it ran for
# Save each command’s beginning timestamp (in seconds since the epoch) and the duration (in seconds)
setopt EXTENDED_HISTORY
# This option is a variant of INC_APPEND_HISTORY in which, where possible,
# the history entry is written out to the file after the command is finished,
# so that the time taken by the command is recorded correctly in the history file in EXTENDED_HISTORY format
setopt INC_APPEND_HISTORY_TIME
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
KEYTIMEOUT=1

# this remaps `vv` to `E` (but overrides `visual-mode`)
# unfortunately `vv` doesn't work due to low keytimeout
bindkey -M vicmd 'V' edit-command-line

# -----------------------
# Completions (zstyle)
# -----------------------

# zstyle pattern:
# :completion:<function>:<completer>:<command>:<argument>:<tag>

# include dotfiles in completion
_comp_options+=(globdots)

# enable caching
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/.zcompcache"

# don't expand aliases before completion has finished
# when on, this option might prevent completions from working with aliases
# see https://unix.stackexchange.com/a/583743/346664
# e.g. try the following with this option on:
#   $ alias g='git'
#   $ g<Tab>  # no completions
unsetopt complete_aliases

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# group ordering configuration
# display different types of matches separately
zstyle ':completion:*' group-name ''
# set descriptions format to enable group support
# fzf-tab will group the results by group description
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# enhanced matcher list with fuzzy matching (smart case)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending
# normally, the completion will not produce the directory names ‘.’ and ‘..’ as possible completions
# this sets special-dirs to ‘..’ when the current prefix is empty, is a single ‘.’, or consists only of a path beginning with ‘../’
zstyle -e ':completion:*' special-dirs \
   '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'

# tag order
# all tags enabled by default
zstyle ':completion:*:complete:-command-:*:*' tag-order \
    'commands builtins aliases functions reserved-words parameters'

# Global tag-order:
# - keep custom option groups (long/short/single-letter) when completing options
# - include `-` to fall back to zsh’s default tag-order for everything else
zstyle ':completion:*' tag-order \
    'options:-long:long\ options
     options:-short:short\ options
     options:-single-letter:single\ letter\ options
     -'

# Helper for option completion gating across inconsistent tag names (`options-*` vs `options`/`option`).
_da__completion_option_ignored_patterns() {
  emulate -L zsh
  local mode="$1"

  if (( CURRENT > 1 )) && [[ ${words[CURRENT-1]} == -- ]]; then
    reply=( "*" )
    return 0
  fi

  case "$mode" in
    long)
      case $PREFIX in
        --*) reply=( "[-+](|-|[^-]*)" ) ;;
        *) reply=( "*" ) ;;
      esac
      ;;
    short)
      case $PREFIX in
        --*) reply=( "*" ) ;;
        -*) reply=( "--*" "[-+]?" ) ;;
        *) reply=( "*" ) ;;
      esac
      ;;
    single-letter)
      case $PREFIX in
        --*) reply=( "*" ) ;;
        -*) reply=( "???*" ) ;;
        *) reply=( "*" ) ;;
      esac
      ;;
    generic)
      case $PREFIX in
        --*) reply=( "+*" "-[^-]*" ) ;;
        -*) reply=( "+*" "--*" ) ;;
        *) reply=( "*" ) ;;
      esac
      ;;
    *)
      reply=( "*" )
      ;;
  esac
}

# Only show options when it makes sense:
# - `--<TAB>` => only long options
# - `-<TAB>`  => only short options
# - after an explicit `--` (end-of-options), never offer options
zstyle -e ':completion:*:*:*:*:options-long' ignored-patterns '
  _da__completion_option_ignored_patterns long
'

zstyle -e ':completion:*:*:*:*:options-short' ignored-patterns '
  _da__completion_option_ignored_patterns short
'

zstyle -e ':completion:*:*:*:*:options-single-letter' ignored-patterns '
  _da__completion_option_ignored_patterns single-letter
'

# Some completions (notably GNU tools like `ls`) use the generic `options`/`option` tag
# rather than `options-long`/`options-short`. Apply the same "only after a dash"
# gating here too.
zstyle -e ':completion:*:*:*:*:options' ignored-patterns '
  _da__completion_option_ignored_patterns generic
'
zstyle -e ':completion:*:*:*:*:option' ignored-patterns '
  _da__completion_option_ignored_patterns generic
'

# Command-position (`-command-`) completion gating:
# - when the command word is empty, keep the default tag-order (allows listing commands)
# - once you start typing a command name, suppress tag-order in this context (reduces noise)
zstyle -e '*:-command-:*' tag-order '
        if [[ -n $PREFIX$SUFFIX ]]; then
          reply=( )
        else
      reply=( - )
    fi'

# treat sequences of slashes in filename paths as a single slash (for example in ‘foo//bar’)
zstyle ':completion:*' squeeze-slashes true
# don't complete options unless the current word starts with '-' (matches "flags only on -/--")
zstyle ':completion:*' complete-options no
zstyle ':completion:*' keep-prefix true

# configure completer (disable corrections / approximate matches)
# Note: Keep comments outside the `zstyle -e` body; it is `eval`'d and some setups
# can treat `# ... (e.g. ...)` as glob patterns under `nomatch`.
zstyle -e ':completion:*' completer '
  reply=(_complete _match)
'
zstyle ':completion:*:approximate:*' max-errors 0

# file sorting configuration
zstyle ':completion:*' file-sort change reverse
zstyle ':completion:*:*:ls:*:*' file-patterns '%p:globbed-files' '*(-/):directories' '*:all-files'
zstyle ':completion:*:*:(cd|pushd):*:*' file-patterns '*(-/):directories'
# enhanced git completions
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-checkout:*' tag-order 'heads:-branch:branch' 'tags:-tag:tag'

# enhanced process/kill completions
# show process details
zstyle ':completion:*:*:kill:*:*' verbose yes
# colorize process list
zstyle ':completion:*:*:kill:*:*' colorize yes
# show only processes (no process groups)
zstyle ':completion:*:*:kill:*' tag-order 'processes'
# custom ps command with full arguments
zstyle ':completion:*:*:kill:*:processes' command 'ps -u $USER -o pid,args -w -w'
# killall process command
zstyle ':completion:*:killall:*' command 'ps -u $USER -o comm'

# respect FZF_DEFAULT_OPTS
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-min-height 18
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' continuous-trigger '/'
#
# fzf-tab adds a leading "·" prefix by default when `:completion:*:descriptions` is set.
# Disable it to avoid dots showing up in the completion list.
zstyle ':fzf-tab:*' prefix ''

# for some reason this ctrl-space binding from the default opts isn't honored
# add it one more time
# fzf-tab uses fzf `--multi`; if nothing is selected (`(0)`), Enter may accept nothing.
# Make Enter/Ctrl-Y always accept the current item.
zstyle ':fzf-tab:*' fzf-bindings \
  'ctrl-space:toggle+down' \
  'enter:select+accept' \
  'ctrl-y:select+accept'
# allow multi-selection by default
zstyle ':fzf-tab:complete:*' fzf-flags '--multi'

# fzf-tab preview commands
# Preview context variables provided by fzf-tab:
# - `$group`: current completion group/label (derived from `:completion:*:descriptions`)
# - `$word`: currently selected candidate (unquoted)
# - `$realpath`: absolute/real path when the candidate is a file/dir (may be empty)
# directory tree preview
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -T -L 2 --color=always $realpath'

# ssh/scp/sftp/etc:
# - for host groups: show ssh config + DNS
# - for file/path groups: preview the path
zstyle ':fzf-tab:complete:(ssh|scp|sftp|rsh|rsync):*' fzf-preview '
  if [[ $group == *host* ]]; then
    ssh -G $word 2>/dev/null | sed -n "1,120p"
    echo
    dig $word
  elif [[ -n $realpath ]]; then
    eza -la --color=always $realpath 2>/dev/null || ls -la $realpath
  fi
'

# rm:
# preview the selected path (type + basic listing + head for regular files)
zstyle ':fzf-tab:complete:rm:*' fzf-preview '
  [[ -n $realpath ]] || exit 0
  (command -v eza >/dev/null 2>&1 && eza -la --color=always "$realpath") || ls -la "$realpath"
  echo
  file -b "$realpath" 2>/dev/null || true
  echo
  if [[ -f $realpath ]]; then
    (command -v bat >/dev/null 2>&1 && bat --color=always --line-range=:120 "$realpath") \
      || sed -n "1,120p" "$realpath"
  fi
'
# systemd status
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
# man page preview
zstyle ':fzf-tab:complete:man:*' fzf-preview 'man $word | head -50'
# bat file preview
zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --line-range=:50 $realpath'
# eza dir preview
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -la --color=always $realpath'

# ssh completion order
zstyle ':completion:*:ssh:argument-1:' tag-order hosts users
# scp completion order
# Avoid forcing `tag-order` here: `scp` completion (`_ssh`) can offer local files,
# remote hosts, and users as alternatives; a restrictive `tag-order` often results
# in only the first group being shown (e.g. hosts only).
# ssh hosts completion
zstyle ':completion:*:(ssh|scp|sftp|rsh|rsync):*:hosts' hosts


# ===============
# EXPORTS START
# To see the full list of active exports, run `export`
# To search, run `exf`
# ===============


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
    alias fd='fd --hidden --follow'

    alias fdf='fd -t f --strip-cwd-prefix --hidden --follow 2>/dev/null'
    alias fdd='fd -t d --strip-cwd-prefix --hidden --follow 2>/dev/null'
    alias fdd1='fd -t d -d 1 --strip-cwd-prefix --hidden --follow 2>/dev/null'
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

# remove directories and their contents recursively
alias rmd='rm -r'
# interactive; prompt before every removal
alias rmi='rm -i'

# copy directories recursively
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
    alias rg='rg --smart-case --hidden --follow'
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

alias pgrep='command pgrep'
alias pkill='command pkill'

# VIM FTW
alias :q='exit'
alias :wq='exit'


# ------------------------
# Observability
# ------------------------

function lsof_port() {
    local port="$1"
    lsof -i ":${port}"
}
alias lsof_inet="lsof -i -P -n"
alias lsof_inet_listen="lsof -i -P -n | grep LISTEN"

# ------------------------
# curl
# ------------------------

# follow redirects by default
alias curl="curl -L"

# by default curl writes to stdout
# download file with the same name as a remote (only filename part is used, the path is cut off)
alias curl_download="curl -O"

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
    local selection=$(fd -t f -d 1 --hidden --follow --color never 2>/dev/null | fzf --multi \
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
    --bind='ctrl-d:+reload(fd -t d -d 1 --hidden --follow --color never 2>/dev/null)' \
    --bind='ctrl-d:+change-preview(eza -T -L 1 --color=always {})' \
    --bind='ctrl-d:+refresh-preview' \
    --bind='ctrl-f:change-prompt(Files ∷ )' \
    --bind='ctrl-f:+reload(fd -t f -d 1 --hidden --follow --color never 2>/dev/null)' \
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

# apply the provided functions ($2...) to all files or dirs found by the provided glob ($1)
# all functions must accept exactly one argument, which would be the path of a found file/dir
#
# or simply use:
#   `fd -t f -g "*.mohidden" -x mv {} ../`
# where {} is a file found by fd search
# the command above moves all files one dir level up
#
# another example: file conversion with successive deletion:
#   `fd -t f -g ".webp" -x ffmpeg_img2jpg {} && rm {}`
# the command above converts all .webp files to .jpg format and then deletes them
#
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
# vi-mode
# -------------------

VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=false
VI_MODE_SET_CURSOR=true
# unset VI_MODE_DISABLE_CLIPBOARD

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
# if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
#     export SDKMAN_DIR="$HOME/.sdkman"
#     source "$HOME/.sdkman/bin/sdkman-init.sh"
# fi

# fzf
# ---

# shell integration
source ~/.fzf.zsh

# specify the default command that fzf shall execute on empty stdin
export FZF_DEFAULT_COMMAND='fd -t f --strip-cwd-prefix --hidden --follow 2>/dev/null'

# see https://github.com/junegunn/fzf#key-bindings-for-command-line
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# also mapped as CTRL-E
export FZF_ALT_C_COMMAND='fd -t d -d 1 --strip-cwd-prefix --hidden --follow 2>/dev/null'

# these default options will be used everytime you call fzf
FZF_MIN_HEIGHT="50%"
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

# these options *extend* and override the default ones above
export FZF_BINDING_OPTS="--border rounded
  --layout default
  --info inline-right
  --color header:italic
  --separator '─'"
export FZF_CTRL_T_OPTS="$FZF_BINDING_OPTS
  --preview 'bat --color=always --style=numbers --line-range=:500 {}'
  --bind 'ctrl-/:change-preview-window(hidden|)'
  "
export FZF_ALT_C_OPTS="$FZF_BINDING_OPTS
  --preview 'eza -T -L 2 --color=always {}'
  --bind 'ctrl-/:change-preview-window(hidden|)'
  "
export FZF_CTRL_R_OPTS="$FZF_BINDING_OPTS
  --preview 'echo {3..}'
  --preview-window down:5:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  "

# CTRL-R - Paste the selected command from history into the command line
# better shell history search
# big thanks to this amazing article https://tratt.net/laurie/blog/2025/better_shell_history_search.html
# adapted for FZF
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob 2> /dev/null
  local awk_filter='{ cmd=$0; sub(/^\s*[0-9]+\**\s+/, "", cmd); if (!seen[cmd]++) print $0 }'  # filter out duplicates
  local n=1 fc_opts=''
  if [[ -o extended_history ]]; then
    awk_filter='
{
  ts = int($2)
  delta = systime() - ts
  delta_days = int(delta / 86400)
  if (delta < 0) { $2="+" (-delta_days) "d" }
  else if (delta_days < 1 && delta < 72000) { $2=strftime("%H:%M", ts) }
  else if (delta_days == 0) { $2="1d" }
  else { $2=delta_days "d" }
  line=$0; $1=""; $2=""
  if (!seen[$0]++) print line
}'
    fc_opts='-i'
    n=2
  fi
  selected=( $(fc -rl $fc_opts -t '%s' 1 | sed -E "s/^ *//" | awk "$awk_filter" |
    FZF_DEFAULT_OPTS=$(__fzf_defaults "" "--with-nth $n.. --scheme=history --bind=ctrl-r:toggle-sort --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} --no-multi") \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    if num=$(awk '{print $1; exit}' <<< "$selected" | grep -o '^[1-9][0-9]*'); then
      zle vi-fetch-history -n $num
    else # selected is a custom query, not from history
      LBUFFER="$selected"
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N            fzf-history-widget
bindkey -M emacs '^R' fzf-history-widget
bindkey -M vicmd '^R' fzf-history-widget
bindkey -M viins '^R' fzf-history-widget

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
    fd --hidden --follow . "$1" 2>/dev/null
}

# Use fd to generate an input for dir completion
function _fzf_compgen_dir() {
    fd -t d --hidden --follow . "$1" 2>/dev/null
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
        cd)           fzf --preview 'eza -T -L 2 --color=always {} | head -200' "$@" ;;
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
!.mp3$      inverse-suffix-exact-match      Items that do not end with .mp3\"
"
# rust regex help (used by rg, fd, and many other Rust-based CLI utils)
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
# Source modular configs
# =====================

for file in "$ZCONFIG_DIR"/source/**/*(.N); do
    source "$file"
done


# =============
# Final config
# ------------
# Depends on the sourced files above or overrides
# =============

# Normalize `open` across Linux, macOS, and Windows
OPEN_CMD='open'
if ! _is_osx; then
    if _is_wsl; then
        OPEN_CMD='explorer.exe'
    else
        OPEN_CMD='xdg-open'
    fi
fi
function open() {
    if [[ -z "$1" ]]; then
        command "$OPEN_CMD"  .
    else
        command "$OPEN_CMD" "$1"
    fi
}

# -----------------------
# Prompt
# -----------------------

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh directly
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# -----------------------
# zoxide
# -----------------------

# --cmd cd will replace the `cd` command
# that is, cd=z, cdi=zi
#
# loaded only on interactive env to be safe
if [[ -o interactive ]]; then
    eval "$(zoxide init zsh --cmd cd)"
fi
