# tmux — Cheat Sheet

tmux is your terminal multiplexer. Prefix is **`C-a`** (Ctrl+a). Key mode is
`vi`, mouse is on (you can drag panes/windows by hand), scrollback is 100000
lines, windows are 1-based.

Full config: `nixos/tmux.nix` → `~/.config/tmux/tmux.conf`.

## Splits & windows (as configured)

| Keys | Action |
|---|---|
| `C-a \|` | New pane **horizontal** (below), starts in cwd |
| `C-a -` | New pane **vertical** (right), starts in cwd |
| `C-a c` | New window, starts in cwd |
| `C-a r` | Reload `tmux.conf` (source + confirm) |
| `C-a [` | Focus pane to the left |
| `C-a ]` | Focus pane to the right |

> The old `"` (split) and `%` (split vertical) keys are **unbound** here and
> replaced by `-` and `\|` above.

## Common (standard tmux defaults still active)

| Keys | Action |
|---|---|
| `C-a :` or `C-a <space>` | Command prompt |
| `C-a d` | Detach |
| `C-a D` | Attach to next session |
| `C-a g` | New window |
| `C-a s` | Split current window |
| `C-a 1`–`C-a 9` | Switch window by number |
| `C-a ?` | List all sessions |
| `C-a %` | — *unbound* on this system |

## Plugins

| Plugin | Behavior |
|---|---|
| `yank` | Mouse-drag select → system clipboard (`@yank_selection_mouse clipboard`) |
| `resurrect` + `continuum` | Auto-save session layout every 15s; restore on next `tmux new` (`@continuum-restore on`, `@resurrect-capture-pane-contents on`) |
| `vim-tmux-navigator` | Navigate windows/panes with vim keys — works from Neovim too |
| `catppuccin` | Mocha theme for the status bar + colors |

## Clipboard & display

From `~/.config/tmux/tmux.conf`:

- `set -g set-clipboard on` — killing a pane copies its contents to the system clipboard
- `set -g renumber-windows on`
- `set -g status-position top`
- `set -g allow-passthrough on`
- `terminal-features` RGB color for `alacritty`, `tmux-256color`
- `extended-keys on` — extra `C-a` combos are available

## References

- `man tmux` — full keybinding list
- tmux wiki: https://github.com/tmux/tmux/wiki
