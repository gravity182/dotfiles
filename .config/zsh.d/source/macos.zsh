#                        ___  ____
#  _ __ ___   __ _  ___ / _ \/ ___|
# | '_ ` _ \ / _` |/ __| | | \___ \
# | | | | | | (_| | (__| |_| |___) |
# |_| |_| |_|\__,_|\___|\___/|____/
#

if ! _is_osx; then
    return 1
fi

# GNU Core Utils
# --------------

export PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH"
export PATH="${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin:$PATH"
export PATH="${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="${HOMEBREW_PREFIX}/opt/gawk/libexec/gnubin:$PATH"
export MANPATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnuman:$MANPATH"
export MANPATH="${HOMEBREW_PREFIX}/opt/findutils/libexec/gnuman:$MANPATH"
export MANPATH="${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnuman:$MANPATH"
export MANPATH="${HOMEBREW_PREFIX}/opt/gawk/libexec/gnuman:$MANPATH"

# ===============
# Aliases
# ===============

# put system to sleep
alias afk='pmset sleepnow'

# caffeinate - keep the mac awake
alias coffee='caffeinate -i -m -t'

# ===============
# Homebrew
# ===============

# print install time
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
# disable analytics
export HOMEBREW_NO_ANALYTICS=1
# auto-update Homebrew every month on install/upgrade/reinstall
export HOMEBREW_AUTO_UPDATE_SECS=2592000
# do not cleanup automatically on install/upgrade/reinstall
export HOMEBREW_NO_INSTALL_CLEANUP=1
# disable env hints
export HOMEBREW_NO_ENV_HINTS=1

# ===============
# iTerm2
# ===============

# shell integration for iTerm2
# https://iterm2.com/documentation-shell-integration.html
[[ ! -e "${HOME}/.iterm2_shell_integration.zsh" ]] && curl -sSfL https://iterm2.com/shell_integration/zsh -o "${HOME}/.iterm2_shell_integration.zsh"
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES
source "${HOME}/.iterm2_shell_integration.zsh"
