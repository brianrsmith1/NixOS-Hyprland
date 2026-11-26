#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$HOME/.config"
BIN="$HOME/.local/bin"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$CONFIG" "$BIN"
for item in hypr waybar kitty fish fuzzel swaync gtk-3.0 gtk-4.0; do
  src="$ROOT/shared/$item"
  [[ -d "$src" ]] || continue
  dest="$CONFIG/$item"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mv "$dest" "${dest}.backup-$STAMP"
  elif [[ -L "$dest" ]]; then
    rm "$dest"
  fi
  ln -sfn "$src" "$dest"
done
ln -sfn "$ROOT/shared/starship.toml" "$CONFIG/starship.toml"
chmod +x "$ROOT/shared/scripts/run-on-discrete-gpu.sh"
ln -sfn "$ROOT/shared/scripts/run-on-discrete-gpu.sh" "$BIN/run-on-discrete-gpu"
echo "Linked shared configs and run-on-discrete-gpu helper. Ensure ~/.local/bin is on PATH."
echo "Existing config directories were backed up with suffix .backup-$STAMP."
