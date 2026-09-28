# Noctalia — Cheat Sheet

Noctalia is the desktop shell on top of niri (a GNOME-like Wayland compositor-
independent environment). It provides the launcher, control center, top panel,
notifications, and a GNOME-style set of default keybinds.

Config lives at `~/.config/noctalia/config.toml` (managed from `nixos/home.nix`).
Your `configuration.nix` enables its recommended services (NetworkManager,
Bluetooth, UPower, power-profile).

## Keybinds on this system

These are remapped in `~/.config/niri/config.kdl` via `noctalia msg …`:

| Key | What |
|---|---|
| `Mod+D` | Open the **launcher** (`noctalia msg panel-toggle launcher`) |
| `Mod+S` | Open the **Control Center** (`noctalia msg panel-toggle control-center`) |
| `Mod+Comma` | Open **Noctalia Settings** (`noctalia msg settings-toggle`) |
| `Super+Alt+L` | **Lock the screen** (`noctalia msg session lock`) |

Everything else follows Noctalia's default keybindings (GNOME-like). See the
wiki below for the full set — don't trust a static list; `niri`'s hotkey
overlay (`Mod+Shift+Slash`) shows the niri-side keys, and Noctalia's settings
panel shows the desktop-side keys.

## Window behavior

The shell runs as one always-floating window, fixed at `1080x920` (the
`dev.noctalia.Noctalia` window-rule in the niri config), so it never gets
tilled with your apps.

## Appearance

From `~/.config/noctalia/config.toml`:

| Setting | Current value | How to change |
|---|---|---|
| Theme mode | `dark` | `light` / `dark` |
| Theme source | `builtin` | `builtin` / `custom` |
| Built-in theme | `Tokyo-Night` | any built-in name |
| Shell font | `JetBrainsMono Nerd Font Propo` | any installed font |
| Wallpaper dir | `~/.config/wallpapers` | path to image files |
| Backdrop | `enabled = true` | `true` / `false` |

## Changing something

Edit `~/.config/noctalia/config.toml` or the niri rule, then rebuild the
flake:

```sh
nrs        # sudo nixos-rebuild switch --flake /home/von/dotfiles/nixos#nixos
nhs        # home-manager switch (user-level changes)
```

After a rebuild, lock/unlock or open the Noctalia settings to pick up theme
and font changes.

## References

- Noctalia (repo + wiki): https://github.com/noctalia-dev/noctalia
- Noctalia wiki (keybindings, themes, config): https://wiki.noctalia.org
- Your live config: `~/.config/noctalia/config.toml`
