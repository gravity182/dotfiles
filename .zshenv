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

path+="$HOME/.local/bin"
path+="$HOME/.arkade/bin"

# Core utils
# ----------

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

