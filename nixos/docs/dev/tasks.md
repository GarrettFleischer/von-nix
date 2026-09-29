# Dev Tasks

## Pomodoro Commit Issues (`619a75d`)

Commit `619a75d` ("Clean up ... add pomodoro + vim keys") introduced two
breaking changes plus one documentation gap.

### 1. PS1 Over-Escaping (terminal prompt broken)

**Symptom:** The shell prompt shows raw escape sequences instead of colors:
```
\e[38;5;34m\]\u\[\e[0m\] in \e[38;5;33m\]\w\[\e[0m\] \\$
```

**Root cause:** The pomodoro commit doubled every backslash in the PS1 line
inside the Nix `''` string in `home.nix`.

In Nix `''` strings, `\\` reduces to `\` at evaluation time. The original
commit `6089225` had `\\e` in the source, which Nix reduces to `\e`, and bash
interprets `\e` as an ESC byte (256-color ANSI prefix).

The pomodoro commit changed `\\e` to `\\\\e`. Nix reduces `\\\\e` to `\\e`,
and bash sees `\\` (literal backslash) followed by `e` (literal character) —
producing the text `\e` instead of an ESC byte.

**Affected line in `nixos/home.nix`:**
```
# Broken (current / HEAD):
PS1='\t \\[\\e[38;5;34m\\]\u\\[\\e[0m\\] in \\e[38;5;33m\\]...

# Fixed (original, from 6089225):
PS1='\t \[\e[38;5;34m\]\u\[\e[0m\] in \[\e[38;5;33m\]\w\[\e[0m\] \\$ '
```

**Fix:** Revert the PS1 line to single backslashes on `\e`, `\]`, `\[` and
double on `\\$`:

```nix
PS1='\t \[\e[38;5;34m\]\u\[\e[0m\] in \[\e[38;5;33m\]\w\[\e[0m\] \\$ '
```

Hex verification: the source file should contain bytes `5C 65` (`\e`) and
`5C 5C 24` (`\\$`), **not** `5C 5C 65` (`\\e`) or `5C 5C 5C 5C 24` (`\\\\$`).

### 2. Missing `pkgs` in Function Signature

**Symptom:** `nixos-rebuild switch` fails with:
```
error: undefined variable 'pkgs'
at /home/von/dotfiles/nixos/home.nix:41:24:
    41|   home.packages = with pkgs; [
```

**Root cause:** The pomodoro commit restructured the home-manager function
from `{ config, pkgs, inputs, ... }:` to `{ inputs, ... }:`, dropping `pkgs`.
However, the body still uses `pkgs` (in `home.packages = with pkgs; [...]`).

**Fix:** Restore `pkgs` in the function signature:
```nix
{ pkgs, inputs, ... }: {
```

### 3. Pomodoro Plugin Limitations (not a config bug)

These are inherent to the pomodoro community plugin, not caused by the
commit but worth documenting:

#### hjkl / Enter don't work in the Pomodoro panel

The pomodoro panel manifest (`plugin.toml`) does not declare
`keyboard_focus` for its `[[panel]]` entry. In Noctalia v5, shell-level
keybinds (`[keybinds]` in `noctalia-config.toml`: `left`, `up`,
`validate`, etc.) only reach panels that opt into keyboard focus. Panels
that don't declare it never receive keyboard navigation events.

This is a **plugin-level** fix — the plugin author needs to add
`keyboard_focus = "on_demand"` to the `[[panel]]` section in:
https://github.com/noctalia-dev/community-plugins/blob/main/pomodoro/plugin.toml

Your `[keybinds]` config in `noctalia-config.toml` is correctly formatted
and still works for Noctalia's own panels (launcher, settings, control
center, session, clipboard, wallpaper).

#### Can't type durations like "3h" or "30m"

The Pomodoro panel has no text input UI elements — only buttons
(Start/Pause, Skip, Reset, Reset All). Duration settings are `int`
(minutes) configured in `[plugin_settings."thepunkoff/pomodoro"]`.

To change a duration (e.g., 3 hours = 180 minutes):
1. Edit the value in `home/noctalia-config.toml` under
   `[plugin_settings."thepunkoff/pomodoro"]`
2. Run `noctalia msg config-reload`
3. Open the panel (`Mod+p`) and click "Reset All" to apply

There is no IPC command to toggle/pause/reset the timer programmatically.
The plugin's TODO list notes "IPC" as pending.

### Verification

After applying fixes:

```bash
# 1. Build succeeds (no Nix eval error)
nixos-rebuild build --flake /home/von/dotfiles/nixos#nixos

# 2. Generated bashrc has correct PS1 bytes
cat /nix/store/...-home-manager-files/.bashrc | grep PS1 | xxd
# Should show: 5c 65 (\\e) and 5c 5c 24 (\\$)

# 3. Live .bashrc is correct
grep PS1 ~/.bashrc | xxd | head -5
# Should show: 5c 65 (\\e) and 5c 5c 24 (\\$)
```

### Summary of Changes

| File | Change | Status |
|------|--------|--------|
| `nixos/home.nix` line 1 | `{ inputs, ... }` → `{ pkgs, inputs, ... }` | Fixed |
| `nixos/home.nix` line 36 | PS1 `\\\\e` → `\\e`, `\\\\$` → `\\$` | Fixed |
| `nixos/home/noctalia-config.toml` | Updated comments documenting pomodoro limitations | Fixed |
| `~/.bashrc` | Replaced Nix-store symlink with real file | Live |
