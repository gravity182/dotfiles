# Lima VM for AI Coding Agents

Sandboxed Linux VMs for running Claude Code and Codex agents via [Lima](https://lima-vm.io/).

## Quick start

```bash
cd ~/IdeaProjects/your-project
vm-dev
```

This creates a VM (if needed), verifies the project is inside a configured shared root, sets git identity, and drops you into the same project path inside the VM.
By default, projects must live under `~/IdeaProjects`, which is mounted at the same path in the guest.

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

Via [mise](https://mise.jdx.dev/): pinned Node.js, Go, Rust, Java Corretto, and uv versions.
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
