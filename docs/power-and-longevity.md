# Power, thermals, OLED and battery longevity

Target: ThinkPad Z16 Gen 1, Ryzen 9 PRO 6950H, Radeon 680M + RX 6500M, OLED touchscreen. Goal: full available performance on AC and lower power use on battery, without speculative firmware tweaks.

## Automatic AC/battery behavior

The NixOS system enables power-profiles-daemon and a udev-triggered systemd service:
- AC connected: request Performance when exposed by the platform; otherwise Balanced.
- On battery: request Power Saver when available; otherwise Balanced.
- Re-evaluate when the AC adapter changes state and once at boot.

On this NixOS branch, the service and udev rule are defined in `configuration.nix`. After generating `hardware-configuration.nix`, review the boot configuration and rebuild. Verify with `powerprofilesctl get` and `powerprofilesctl list`.

Some firmware/platform combinations do not expose Performance; the helper falls back safely. Profile selection does not guarantee higher benchmark scores or improved runtime. Do not run TLP and power-profiles-daemon together.

## OLED touchscreen

- Use comfortable but modest brightness on battery; brightness is usually a larger lever than theme choice.
- Keep the dark graphite/Catppuccin theme. Dark pixels can reduce OLED power use, but application content and brightness dominate; a dark theme alone does not guarantee longer runtime.
- Keep touchscreen enabled for normal use. Disabling touch only when unused is optional and should be tested for actual power impact.
- Use Hypridle/screen blanking and a short battery timeout; avoid leaving static bright UI elements on screen for long periods.
- Do not force refresh rate or HDR until supported modes and actual power impact have been measured. Test a lower supported refresh rate on battery.
- A dark theme alone does not prevent burn-in.

## Hybrid graphics

Use Radeon 680M for the desktop and routine applications. Keep RX 6500M idle when unused where kernel and firmware permit; launch demanding applications selectively with `DRI_PRIME=1` using `run-on-discrete-gpu`. Confirm with `glxinfo -B`, `vulkaninfo --summary`, and power measurements. Do not force the dGPU globally.

## Thermal and battery policy

- Keep Lenovo firmware defaults initially; no generic undervolts, forced boost limits, fan curves or speculative kernel parameters.
- Performance mode on AC can increase heat, fan noise and power draw. Use it for plugged-in workloads; Balanced is a sensible fallback.
- Avoid routinely holding the battery at 100% while docked. Check whether firmware exposes charge thresholds; configure only supported controls.
- Use an adequately rated Lenovo/USB-C charger and keep vents clear.
- Compare Windows and Fedora under matching brightness, refresh rate, Wi-Fi, workload and starting charge. Record discharge rate (W) and runtime; do not assume Linux is more efficient.

## Useful checks

```sh
powerprofilesctl get
powerprofilesctl list
upower -d
cat /sys/class/power_supply/BAT0/energy_full
cat /sys/class/power_supply/BAT0/energy_full_design
```

Battery supply names vary; inspect `/sys/class/power_supply/` if BAT0 is absent. Keep periodic SSD TRIM enabled, maintain free space, and review battery capacity/cycle count quarterly.
