#!/usr/bin/env bash
#
# Build the self-contained `.#nvim` (config loaded via `-u <initFile>`, so
# ~/.config/nvim is never consulted) and run scripts/check-keymaps.lua in it
# headlessly, inside a throwaway HOME. `nix flake check` runs the same Lua
# file as `checks.keymaps`; this script is the local shortcut (`just test`).
#
# Set NVIM=/path/to/nvim to skip the build and test an existing binary.

set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -z "${NVIM:-}" ]]; then
  echo "==> Building .#nvim ..."
  NVIM="$(nix build --no-link --print-out-paths .#nvim)/bin/nvim"
fi

tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT
mkdir -p "$tmp_home/.local/share/nvim" "$tmp_home/.local/state/nvim" \
  "$tmp_home/.cache/nvim" "$tmp_home/.config"

echo "==> Checking config contracts in a headless nvim ..."
HOME="$tmp_home" timeout 120 "$NVIM" --headless -c "luafile scripts/check-keymaps.lua"
