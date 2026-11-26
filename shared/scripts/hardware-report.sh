#!/usr/bin/env bash
set -u
echo "=== System ==="
for f in /sys/class/dmi/id/sys_vendor /sys/class/dmi/id/product_name /sys/class/dmi/id/product_version /sys/class/dmi/id/bios_version; do
  [[ -r "$f" ]] && printf '%s: %s\n' "$(basename "$f")" "$(cat "$f")"
done
echo; echo "=== CPU ==="; lscpu 2>/dev/null | grep -E 'Model name|CPU\(s\)|Architecture' || true
echo; echo "=== Graphics / Network ==="; lspci -nnk 2>/dev/null | grep -A3 -Ei 'VGA|Display|3D|Network controller' || true
echo; echo "=== Battery ==="
for b in /sys/class/power_supply/BAT*; do
  [[ -d "$b" ]] || continue
  for f in status capacity cycle_count energy_full_design energy_full charge_control_start_threshold charge_control_end_threshold; do
    [[ -r "$b/$f" ]] && printf '%s: %s\n' "$f" "$(cat "$b/$f")"
  done
done
echo; echo "=== Sleep modes ==="; [[ -r /sys/power/mem_sleep ]] && cat /sys/power/mem_sleep || true
echo; echo "=== Firmware ==="; command -v fwupdmgr >/dev/null && fwupdmgr get-devices 2>/dev/null | head -60 || true
