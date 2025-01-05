# __        ______  _
# \ \      / / ___|| |
#  \ \ /\ / /\___ \| |
#   \ V  V /  ___) | |___
#    \_/\_/  |____/|_____|
#

if ! _is_wsl; then
    return 1
fi

# -------------------
# WSL Configuration
# -------------------

alias wslconfig="sudo $EDITOR /etc/wsl.conf"
alias wslcfg='wslconfig'

wuser="ersho"

# functions
# -------------------

# Mount a removable USB drive
function mount_usb() {
    if [[ -z "$1" ]]; then
        echo "Please provide a USB letter!"
        return 1
    fi
    sudo mkdir -p /mnt/$1 && \
        sudo mount -t drvfs $1: /mnt/$1 -o uid=$(id -u $USER),gid=$(id -g $USER),metadata
}

# directory shortcuts
# -------------------

# C drive
hash -d c="/mnt/c/Users/$wuser"
hash -d w="/mnt/c/Users/$wuser"
hash -d idea="/mnt/c/Users/$wuser/Documents/IdeaProjects"
hash -d mods="/mnt/c/Users/$wuser/AppData/Local/ModOrganizer/Skyrim Special Edition/mods/SSEEdit Patch"

# D drive
hash -d d="/mnt/d"


# commands (interop)
# ----------------

# you can use this tool (available exclusively in WSL) to copy any text content into Windows' paste buffer
# $ echo "123" | clip
alias 'clip.exe'='/mnt/c/WINDOWS/System32/clip.exe'
alias clip='clip.exe'

# code is already defined when running from VSCode
if ! command code -v &>/dev/null; then
    alias code='/mnt/c/Users/$wuser/AppData/Local/Programs/Microsoft\ VS\ Code/code.exe'
fi

alias 'explorer.exe'='/mnt/c/WINDOWS/explorer.exe'
alias explorer='explorer.exe'

alias 'powershell.exe'='/mnt/c/Program\ Files/PowerShell/7/pwsh.exe -WorkingDirectory .'
alias powershell='powershell.exe'

alias 'firefox.exe'='/mnt/c/Program\ Files/Mozilla\ Firefox/firefox.exe'
alias firefox="firefox.exe"


# vscode
# ----------------

# doesn't work reliably
# try running a usual terminal first, then run a vscode's integrated terminal
# you'll get the following error message:
#   Command is only available in WSL or inside a Visual Studio Code terminal.
#
# but I doubt that I need this integration - never used it
# see https://github.com/microsoft/vscode-remote-release/issues/2763
# if [[ -n "$VSCODE" ]]; then
#     if ! source "$(code --locate-shell-integration-path zsh)"; then
#         echo "Couldn't source the vscode shell integration script" >&2
#     else
#         echo "Sourced the vscode shell integration script"
#     fi
# fi

