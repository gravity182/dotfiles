# Lima VM for AI Coding Agents

Sandboxed Linux VMs for running Claude Code and Codex agents via [Lima](https://lima-vm.io/).

## Quick start

```bash
cd ~/your-project
vm-dev
```

This creates a VM (if needed), mounts the project directory, sets git identity, and drops you into the VM.

## Functions

| Function | Description |
|---|---|
| `vm-dev [name]` | Main entry point -- mount CWD and shell into VM |
| `vm-create [name]` | Create and provision a new VM |
| `vm-sync-configs [name]` | Sync Claude/Codex configs into VM |
| `vm-ssh [name]` | SSH into VM |
| `vm-start [name]` | Start VM |
| `vm-stop [name]` | Stop VM |
| `vm-rm [name]` | Delete VM |
| `vm-list` | List VMs |
| `vm-clone <src> <dst>` | Clone a VM |

Default VM name: `dev`.

## What gets provisioned

Via [mise](https://mise.jdx.dev/): Node.js (LTS), Go, Rust.
Directly: Docker, GitHub CLI, Claude Code, Codex.

## Manual login required per VM

- `claude login`
- `gh auth login`

Codex auth is synced automatically.

## SSH access

Each VM gets an SSH config at `~/.ssh/config.d/lima-<name>`. To use `vm-ssh` or `ssh lima-dev`, add this line to the top of `~/.ssh/config`:

```
Include config.d/*
```

## Files

- `vm-template.yaml` -- Lima VM template (image, mounts, provision)
- `vm-provision.sh` -- provisioning script that runs inside the VM
- Shell functions live in `~/.config/zsh.d/source/lima.zsh`
