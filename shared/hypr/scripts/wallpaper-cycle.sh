#!/usr/bin/env bash
set -euo pipefail
WALLPAPER_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpapers"
[[ -d "$WALLPAPER_DIR" ]] || { echo "Create $WALLPAPER_DIR and add image files first." >&2; exit 1; }
mapfile -d '' wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0)
(("${#wallpapers[@]}" > 0)) || { echo "No supported wallpapers found in $WALLPAPER_DIR." >&2; exit 1; }
command -v swww >/dev/null 2>&1 || { echo "swww is not installed." >&2; exit 1; }
swww img "${wallpapers[RANDOM % ${#wallpapers[@]}]}" --transition-type fade --transition-duration 1
