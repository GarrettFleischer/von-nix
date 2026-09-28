#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: ./setup-hermes.sh OPENROUTER_API_KEY

Writes the Hermes API key to ~/.config/hermes/env, updates the hermes-agent flake input,
and rebuilds the NixOS flake.
USAGE
}

if [ "$#" -ne 1 ]; then
  usage
  exit 2
fi

api_key="$1"

if [ -z "$api_key" ]; then
  usage
  exit 2
fi

case "$api_key" in
  sk-or-*|sk-ant-*|sk-proj-*|sk-*) ;;
  *)
    printf 'Warning: API key does not look like a common OpenRouter, Anthropic, or OpenAI key. Continuing.\n' >&2
    ;;
esac

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
flake_dir="$script_dir/nixos"
env_dir="$HOME/.config/hermes"
env_file="$env_dir/env"

mkdir -p "$env_dir"
chmod 700 "$env_dir"

umask 077
printf 'OPENROUTER_API_KEY=%s\n' "$api_key" > "$env_file"
chmod 600 "$env_file"

if command -v nix >/dev/null 2>&1; then
  nix flake update hermes-agent --flake "$flake_dir"
else
  printf 'Error: nix not found. Install Nix or run this on the NixOS host.\n' >&2
  exit 127
fi

sudo nixos-rebuild switch --flake "$flake_dir#nixos"

printf 'Hermes setup done. Secret written to %s\n' "$env_file"
