# von-nix

NixOS + **niri** (Wayland compositor) + **Noctalia** (GNOME-like desktop) +
**Zen** (default browser) + **Home Manager**.

This is a git clone of `GarrettFleischer/von-nix`. On the NixOS box the same
repo lives at `/home/von/dotfiles/nixos` — rebuilds run there (the `nrs`/`nhs`
aliases point at that path).

## Docs

All cheat sheets live in `docs/`:

| Sheet | Covers |
|---|---|
| [docs/niri.md](docs/niri.md) | niri keybinds, layout, window rules, workspaces |
| [docs/noctalia.md](docs/noctalia.md) | Noctalia toggles, theme, font, backdrop, wallpaper |
| [docs/tmux.md](docs/tmux.md) | tmux splits/windows, the custom keys, plugins |
| [docs/neovim.md](docs/neovim.md) | full Neovim keymap, LSP, DAP, plugins |
| [docs/shortcuts.md](docs/shortcuts.md) | aliases, helper scripts, shell & git |
| [docs/manuals.md](docs/manuals.md) | curated link list (NixOS, niri, Noctalia, Zen, …) |

## Structure

| Path | What |
|---|---|
| `nixos/configuration.nix` | system: niri, Noctalia, Zen, services, user `von` |
| `nixos/home.nix` | user: `~/.config/niri/config.kdl` + `~/.config/noctalia/config.toml` |
| `nixos/neovim.nix` | Neovim packages, LSP binaries, plugin wrapper; lua in `nvim/` |
| `nixos/tmux.nix` | tmux config |
| `nvim/` | Neovim lua config (`require("von")`) |
| `wallpapers/` | wallpaper images |

## Rebuild

| Command | Does |
|---|---|
| `nrs` | `sudo nixos-rebuild switch --flake /home/von/dotfiles/nixos#nixos` (system) |
| `nhs` | `home-manager switch --flake /home/von/dotfiles/nixos#nixos` (user) |
| `./rebuild.sh` | same as `nrs` |
| `./edit.sh` | opens `nixos/configuration.nix` in vi |

See [docs/shortcuts.md](docs/shortcuts.md) for all aliases and scripts.
