#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$HOME/.config"
BIN="$HOME/.local/bin"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$CONFIG" "$BIN"
backup_target() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then mv "$target" "${target}.backup-$STAMP"
  elif [[ -L "$target" ]]; then rm "$target"; fi
}
for item in hypr waybar kitty fish fuzzel swaync gtk-3.0 gtk-4.0; do
  src="$ROOT/shared/$item"
  [[ -d "$src" ]] || continue
  dest="$CONFIG/$item"
  backup_target "$dest"
  ln -s "$src" "$dest"
done
backup_target "$CONFIG/starship.toml"
ln -s "$ROOT/shared/starship.toml" "$CONFIG/starship.toml"
backup_target "$BIN/run-on-discrete-gpu"
chmod +x "$ROOT/shared/scripts/run-on-discrete-gpu.sh"
ln -s "$ROOT/shared/scripts/run-on-discrete-gpu.sh" "$BIN/run-on-discrete-gpu"
echo "Linked shared configs and run-on-discrete-gpu helper. Ensure ~/.local/bin is on PATH."
echo "Existing config files/directories were backed up with suffix .backup-$STAMP."
