# Niri — Cheat Sheet

Niri is the Wayland compositor for this setup (default GDM session).
Every key below is taken from `nixos/home.nix` → `~/.config/niri/config.kdl`, so it matches your live config exactly.

`Mod` = the Super/Windows key. `Super` is the same physical key; the config uses both spellings.

## Window & column movement

| Keys | Action |
|---|---|
| `Mod+h` / `Mod+l` | Focus column left / right |
| `Mod+k` / `Mod+j` | Focus window up / down |
| `Mod+Shift+h` / `Mod+Shift+l` | **Move** column left / right |
| `Mod+Shift+1..9` | **Move column** to workspace (cyclic `a`/`b`/`c`: 1→a, 2→b, 3→c, 4→a, …) |
| `Mod+U` / `Mod+I` | Focus workspace down / up |
| `Mod+Ctrl+U` / `Mod+Ctrl+I` | Move column to workspace down / up |
| `Mod+[` / `Mod+]` | Consume or expel window left / right |
| `Mod+R` | Switch preset column width |
| `Mod+F` | Maximize the column |
| `Mod+V` | Toggle window floating / tiled |
| `Mod+Shift+V` | Switch focus between floating and tiled sets |

## System & apps

| Keys | Action |
|---|---|
| `Mod+Return` | Open a terminal (alacritty) |
| `Mod+Q` | Close the focused window |
| `Mod+Shift+E` | Quit niri |
| `Mod+D` | Open the **launcher** (Noctalia) |
| `Mod+S` | Open the **Control Center** (Noctalia) |
| `Mod+Comma` | Open **Noctalia Settings** |
| `Mod+M` | Open **YouTube Music** (`alacritty -e ytm`) |
| `Mod+Shift+T` | Open **btop** (`alacritty -e btop`) |
| `Mod+W` | Open the **Wallhaven** browser |
| `Mod+Shift+W` | Open the **video wallpaper** picker |
| `Super+Alt+L` | **Lock the screen** |
| `Mod+Shift+Slash` | Show the **hotkey overlay** (niri's "important hotkeys") |

Tip: `Mod+Shift+Slash` is the fastest way to remember the full list — it's always correct for your config.

## Layout & appearance

From the same config:

- `gaps 12` between windows.
- `default-column-width { proportion 0.5 }` — two equal columns.
- `always-center-single-column` — a lone window on a workspace opens **centered** (not left).
- Window `geometry-corner-radius 8`, clipped to its geometry.
- Focus ring and border are off.

## Workspaces

Three: `a`, `b`, `c` (`workspace "a"` / `workspace "b"` / `workspace "c"` in the config).

## Noctalia on top

The desktop shell is configured as its own window rule: floating, `1080x920`, on a workspace. Noctalia-specific keys (launcher, control-center, settings, lock) are wired through `noctalia msg …` — see [Noctalia →](noctalia.md).

## References

- Niri (repo + wiki): https://github.com/wilmor/niri
- NixOS `programs.niri` option: https://nixos.org/manual/nixos/stable/options#opt-programs.niri
- Your live config: `~/.config/niri/config.kdl` (managed from `nixos/home.nix`)
