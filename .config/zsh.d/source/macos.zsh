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

for gbin in /opt/homebrew/opt/*/libexec/gnubin; do
  export PATH="$gbin:$PATH"
done
for gman in /opt/homebrew/opt/*/libexec/gnuman; do
  export MANPATH="$gman:$MANPATH"
done

# ===============
# MISCELLANEOUS
# ===============

if [[ $TERM_PROGRAM =~ "iTerm" ]]; then
    # integration between zsh and iterm2
    [[ ! -e "${HOME}/.iterm2_shell_integration.zsh" ]] && curl -L https://iterm2.com/shell_integration/zsh -o "${HOME}/.iterm2_shell_integration.zsh"
    source "${HOME}/.iterm2_shell_integration.zsh"
fi

