# Lima VM management functions

VM_TEMPLATE="$HOME/scripts/lima/vm-template.yaml"
VM_DEFAULT_NAME="dev"

# Sync Claude Code and Codex configs into a running VM
vm-sync-configs() {
    local name="${1:-$VM_DEFAULT_NAME}"
    local staging="$HOME/VM-Shared/_configs"

    echo "Syncing agent configs into VM '$name'..."
    rm -rf "$staging"
    mkdir -p "$staging/claude" "$staging/codex"

    # Claude Code configs
    for item in CLAUDE.md settings.json agents commands hooks rules; do
        [[ -e "$HOME/.claude/$item" ]] && cp -r "$HOME/.claude/$item" "$staging/claude/"
    done

    # Codex configs (including auth.json for login persistence)
    for item in AGENTS.md config.toml auth.json rules skills; do
        [[ -e "$HOME/.codex/$item" ]] && cp -r "$HOME/.codex/$item" "$staging/codex/"
    done

    # Place configs inside the VM
    limactl shell "$name" bash -c '
        mkdir -p ~/.claude ~/.codex
        for item in ~/Shared/_configs/claude/*; do
            [ -e "$item" ] && cp -r "$item" ~/.claude/
        done
        for item in ~/Shared/_configs/codex/*; do
            [ -e "$item" ] && cp -r "$item" ~/.codex/
        done
        echo "  Claude configs: $(ls ~/.claude/ 2>/dev/null | tr "\n" " ")"
        echo "  Codex configs:  $(ls ~/.codex/ 2>/dev/null | tr "\n" " ")"
    '

    rm -rf "$staging"
    echo "Config sync complete."
}

# Create and provision a new VM (one-time setup)
vm-create() {
    local name="${1:-$VM_DEFAULT_NAME}"

    echo "Creating VM '$name'..."
    if ! limactl start --name "$name" --tty=false "$VM_TEMPLATE"; then
        echo "Error: Failed to create VM '$name'."
        return 1
    fi

    # Link SSH config
    mkdir -p "$HOME/.ssh/config.d"
    ln -sf "$HOME/.lima/$name/ssh.config" "$HOME/.ssh/config.d/lima-$name"
    echo "SSH config linked: ssh lima-$name"

    # Sync agent configs
    vm-sync-configs "$name"

    echo ""
    echo "Done! VM '$name' is ready."
    echo "  Use 'vm-dev' from a project directory to start working."
}

# Main entry point: mount CWD in VM, set git identity, SSH into project
vm-dev() {
    local name="${1:-$VM_DEFAULT_NAME}"
    local project_dir="$PWD"

    # Check if VM exists
    if ! limactl list --json 2>/dev/null | grep -q "\"name\":\"$name\""; then
        echo "VM '$name' does not exist. Creating it..."
        vm-create "$name" || return 1
    fi

    # Ensure VM is running
    local vm_status=$(limactl list --json 2>/dev/null | jq -r "select(.name==\"$name\") | .status")
    if [[ "$vm_status" != "Running" ]]; then
        echo "Starting VM '$name'..."
        limactl start "$name"
    fi

    # Check if CWD is already mounted
    local lima_yaml="$HOME/.lima/$name/lima.yaml"
    if ! grep -q "location: .*$project_dir" "$lima_yaml" 2>/dev/null; then
        echo "New mount required: $project_dir"
        echo "This will restart the VM. Continue? [y/N] "
        read -r confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || return 1
        limactl stop "$name"
        limactl edit "$name" --mount "${project_dir}:w" --start
    fi

    # Detect and set per-repo git identity
    local git_name git_email
    git_name=$(git config user.name 2>/dev/null || true)
    git_email=$(git config user.email 2>/dev/null || true)

    if [[ -n "$git_name" && -n "$git_email" ]]; then
        echo "Git identity: $git_name <$git_email>"
        limactl shell "$name" env \
            GIT_NAME="$git_name" \
            GIT_EMAIL="$git_email" \
            PROJECT_DIR="$project_dir" \
            bash -c 'git -C "$PROJECT_DIR" config user.name "$GIT_NAME" && git -C "$PROJECT_DIR" config user.email "$GIT_EMAIL"'
    fi

    echo "Connecting to VM '$name' at $project_dir..."
    limactl shell --workdir "$project_dir" "$name"
}

vm-ssh() {
    local name="${1:-$VM_DEFAULT_NAME}"
    ssh "lima-$name"
}

vm-stop() {
    local name="${1:-$VM_DEFAULT_NAME}"
    limactl stop "$name"
}

vm-start() {
    local name="${1:-$VM_DEFAULT_NAME}"
    limactl start "$name"
}

vm-rm() {
    local name="${1:-$VM_DEFAULT_NAME}"
    limactl delete "$name" -f
    rm -f "$HOME/.ssh/config.d/lima-$name"
    echo "VM '$name' deleted and SSH config removed."
}

vm-list() {
    limactl list
}

vm-clone() {
    local src="${1:?Usage: vm-clone <source> <target>}"
    local dst="${2:?Usage: vm-clone <source> <target>}"

    echo "Stopping '$src' for cloning..."
    limactl stop "$src" 2>/dev/null || true

    limactl clone "$src" "$dst" --start=false
    echo "Clone created. Starting '$dst'..."
    limactl start "$dst"

    # Link SSH config for the clone
    mkdir -p "$HOME/.ssh/config.d"
    ln -sf "$HOME/.lima/$dst/ssh.config" "$HOME/.ssh/config.d/lima-$dst"

    echo "Done! Connect with: vm-ssh $dst"

    # Restart source
    echo "Restarting '$src'..."
    limactl start "$src"
}
