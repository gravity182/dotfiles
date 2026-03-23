# Keybindings

Compact reference for the current Zed + IntelliJ/IdeaVim setup.

## Core Map

### Global

| Key | Action | Notes |
| --- | --- | --- |
| `Ctrl-Tab` | Switcher |  |
| `Cmd-Shift-Left` | Previous tab |  |
| `Cmd-Shift-Right` | Next tab |  |
| `Cmd-Alt-Left` | Back |  |
| `Cmd-Alt-Right` | Forward |  |
| `Alt-X` | Close current item |  |
| `Cmd-W` | Expand selection |  |
| `Cmd-Shift-W` | Shrink selection |  |
| `Cmd-Enter` | Code actions |  |

### `g` Namespace

| Key | Action | Notes |
| --- | --- | --- |
| `gd` | Quick target inspection | Intentionally behaves differently in Idea |
| `gD` | Go to declaration |  |
| `gy` | Go to type definition |  |
| `gI` | Go to implementation |  |
| `gu` | Show usages | Idea only |
| `gA` | Find usages / references |  |
| `gh` | Hover / docs |  |
| `g.` | Code actions |  |
| `gs` | Current-file symbols |  |
| `gS` | Project symbols |  |
| `g/` | Project search |  |

### `space f`

| Key | Action | Notes |
| --- | --- | --- |
| `Space F F` | File finder |  |
| `Space F E` | Project panel |  |
| `Space F A` | Action / command search |  |
| `Space F C` | Go to class | Idea only |
| `Space F T` | Television file picker | Zed only |

### `space g`

| Key | Action | Notes |
| --- | --- | --- |
| `Space G G` | Primary git interface | `lazygit` in Zed, VCS popup in Idea |
| `Space G B` | Blame / annotate |  |
| `Space G D` | Diff | Approximate parity |
| `Space G H` | File history |  |
| `Space G L` | Git log / graph | Approximate parity |
| `Space G U` | `gitu` | Zed only |

### Actions / Comments / Diagnostics

| Key | Action | Notes |
| --- | --- | --- |
| `Space A` | Code actions |  |
| `Space R` | Refactor surface | Code actions in Zed, refactor popup in Idea |
| `Space C C` | Comment line |  |
| Visual `Space C` | Comment selection |  |
| `Space D` | Problems / diagnostics |  |
| `Space E` | Toggle left dock | Zed only |
| `Space T` | New center terminal | Zed only |

### Bracket Motions

| Key | Action | Notes |
| --- | --- | --- |
| `[d` / `]d` | Previous / next diagnostic |  |
| `[c` / `]c` | Previous / next git change |  |
| `[m` / `]m` | Previous / next method |  |

### Other Useful Keys

| Key | Action | Notes |
| --- | --- | --- |
| `0` | First non-whitespace |  |
| `Y` | Yank to end of line |  |
| `Shift-K` | Hover / docs | Zed only |
| `K` | Hover / docs | Idea only |
| Visual `Shift-S` | Add surrounds | `vim-surround` in Idea |
| Visual `Shift-J / Shift-K` | Move selected lines down / up |  |

## Zed Extras

- `Cmd-Alt-C` opens the `codex` task in a center pane.
- `Ctrl-W h/j/k/l` moves between docks.
- `Shift Shift` is left to the default JetBrains keymap behavior.

## Idea Extras

- `Space I` = generate
- `Space K` = quick docs
- `Space C` = copy reference popup
- `Space Z` = zen mode
- `Ctrl-J / Ctrl-K` = editor down / up
- Russian layout transliteration mappings are enabled

## Notes

- Formatting uses native editor shortcuts, not leader mappings:
  - Zed JetBrains keymap: `Cmd-Alt-L`
  - Idea: `ReformatCode`
- `gd` is intentionally not strict parity.
- `gu` stays Idea-only because Zed does not expose a distinct “show usages” surface.
