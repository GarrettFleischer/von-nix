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
| `Mod+M` | Open **YouTube Music** in Alacritty (`ytm`) |
| `Mod+Shift+T` | Open **btop** in Alacritty |
| `Mod+W` | Open the **Wallhaven** browser (`noctalia msg panel-toggle noctalia/wallhaven:browser`) |
| `Mod+Shift+W` | Open the **video wallpaper** picker (`noctalia msg panel-toggle noctalia/mpvpaper:picker`) |
| `Super+Alt+L` | **Lock the screen** (`noctalia msg session lock`) |

Everything else follows Noctalia's default keybindings (GNOME-like). See the
docs below for the full set — don't trust a static list; `niri`'s hotkey
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
| Wallpaper dir | `/home/von/dotfiles/wallpapers` | path to image files |
| Wallpaper fill | `crop` | `center` / `crop` / `fit` / `stretch` / `repeat` / `span` |
| Wallpaper transitions | fade, wipe, disc, stripes, zoom, honeycomb (1200ms, one picked at random) | `[wallpaper].transition` |
| Backdrop | `enabled = true` | `true` / `false` |

## Bar, desktop, and plugins

Left bar, top to bottom in the middle: clock, a short audio spectrum (`audio-vis`), the bongo cat, then the pomodoro widget. The cat taps and flashes only while an MPRIS player is playing. Wallhaven and the video-wallpaper glyphs sit with the local wallpaper picker at the top of the bar. Just under that, CPU and RAM gauges show percent. Hover either gauge for the rest of the sampled stats, including RAM in GiB.

On `Virtual-1`, the top-left holds scrolling CPU and RAM graphs. The right gutter holds a now-playing card and a circular `bars_rings` visualizer, both hidden when nothing is playing.

Enabled plugins, besides `von/pomodoro`:

| Plugin | What |
|---|---|
| `noctalia/wallhaven` | Search Wallhaven and download into `~/.local/share/wallpapers` |
| `noctalia/mpvpaper` | Video wallpapers (`mp4`, `webm`, `mkv`, `mov`, `gif`) from `~/Videos` |
| `noctalia/bongocat` | The bar cat |
| `noctalia/wallpaper_depth` | Depth masks so desktop widgets sit behind a still wallpaper |

Depth needs a one-time model install: `noctalia msg panel-toggle noctalia/wallpaper_depth:manager`, then Install model. YouTube Music is `ytm` in a terminal; the first run is `ytm setup`.

## Changing something

Edit `~/.config/noctalia/config.toml` or the niri rule, then rebuild the
flake:

```sh
nrs        # sudo nixos-rebuild switch --flake /home/von/dotfiles/nixos#nixos
nhs        # home-manager switch (user-level changes)
```

After a rebuild, lock/unlock or open the Noctalia settings to pick up theme
and font changes.

## How settings work (two layers)

| Layer | Path | Who writes it |
|---|---|---|
| Base | `~/.config/noctalia/config.toml` | You (via `home.nix`) |
| GUI overrides | `~/.local/state/noctalia/settings.toml` | Noctalia (Settings, setup flows, IPC) |

Precedence: built-in defaults → your `*.toml` (sorted, merged) →
`settings.toml`. **State wins per-key.** Both layers hot-reload, no
restart needed.

- UI changes are **not** written to `~/.config` and **survive every
  rebuild** — Home Manager never touches `~/.local/state` (Noctalia's docs
  call out NixOS read-only config as the use case).
- Hand-edited keys the GUI has touched are shadowed; to check: temporarily
  move `settings.toml` from the state dir, or run `noctalia config validate`
  (newer versions flag overridden keys).
- `plugins.enabled`, `wallpaper.directory`, and `wallpaper.fill_mode` were
  removed from the state file once so the managed `config.toml` is what
  applies. Putting them back in the GUI shadows the managed values again.
- Snapshot UI settings into dotfiles:
  ```sh
  noctalia config export > /home/von/dotfiles/nixos/noctalia-ui-settings.toml
  ```
  (`config export` = explicit config + GUI overrides, built-in defaults
  omitted; `config export full` includes them. Settings menu also has
  "Export Config...".)

## References

- Noctalia (repo + docs): https://github.com/noctalia-dev/noctalia
- Noctalia docs (keybindings, themes, config): https://docs.noctalia.dev/noctalia/
- Your live config: `~/.config/noctalia/config.toml`
