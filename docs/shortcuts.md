# Shortcuts — System, Shell & Commands

The "everything else" sheet: shell aliases, the repo helper scripts, your
prompt, and common commands. Desktop keybinds live in
[docs/niri.md](niri.md) and [docs/noctalia.md](noctalia.md).

## Bash aliases (from `home.nix`)

| Alias | Expands to |
|---|---|
| `vi` | `nvim` |
| `btw` | `echo i use nixos btw` |
| `nrs` | `sudo nixos-rebuild switch --flake /home/von/dotfiles/nixos#nixos && source ~/.bashrc` |
| `nhs` | `home-manager switch --flake /home/von/dotfiles/nixos#nixos && source ~/.bashrc` |
| `nec` | `nvim /home/von/dotfiles/nixos/configuration.nix` |
| `neh` | `nvim /home/von/dotfiles/nixos/home.nix` |

`nrs` = system rebuild (sudo), `nhs` = user (home-manager) rebuild, `nec`/`neh`
open the two main Nix config files in Neovim.

## Prompt

PS1: `\t \[\e[38;5;34m\]\u\[\e[0m\] in \[\e[38;5;33m\]\w\[\e[0m\] \\$ ` →
`<time>  <user> in <cwd> $` (blue user, green path).

## Repo helper scripts (root of `F:/Development/von-nix` / `/home/von/dotfiles/nixos`)

| Script | Does |
|---|---|
| `./edit.sh` | `vi ./nixos/configuration.nix` (run from repo root — relative path) |
| `./rebuild.sh` | `sudo nixos-rebuild switch --flake /home/von/dotfiles/nixos#nixos` |
| `./rebuild-flake.sh` | same as `rebuild.sh` |

## NixOS rebuild (without the aliases)

```sh
sudo nixos-rebuild switch --flake /home/von/dotfiles/nixos#nixos   # system
home-manager switch --flake /home/von/dotfiles/nixos#nixos          # user
nixos-rebuild build --flake /home/von/dotfiles/nixos#nixos          # check build
```

## Common shell

```sh
cd -                 # previous directory
grep -Rni 'pat' .    # recursive search, line numbers, ignore case
watch -n1 'top'      # live process view
man <cmd>             # manual page
history | tail        # recent commands
```

## Common git (repo is on branch `master`, remote `origin`)

```sh
git status                 # what's changed
git add -A && git commit -m 'msg'
git push
git pull                   # merge upstream
git log -1 --oneline       # last commit
git branch -a
git diff                   # unstaged changes
git diff --staged          # staged changes
```

## Full Neovim keymap

See [docs/neovim.md](neovim.md) — the complete Neovim cheatsheet.
