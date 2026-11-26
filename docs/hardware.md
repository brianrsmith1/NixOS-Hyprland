# ThinkPad Z16 Gen 1 — NixOS hardware profile

Target configuration:
- CPU: AMD Ryzen 9 PRO 6950H (8 cores / 16 threads).
- Integrated GPU: AMD Radeon 680M.
- Discrete GPU: AMD Radeon RX 6500M (4 GB GDDR6).
- Memory: 32 GB RAM.

The Z16 Gen 1 shipped in multiple configurations. Confirm the actual hardware before relying on these assumptions.

## Graphics
NixOS uses the in-kernel amdgpu driver and Mesa/RADV. The 680M is the low-power default for Hyprland, Waybar, browsers and video playback. Use the RX 6500M selectively for games or GPU-heavy work.

The shared helper launches a command with Mesa DRI_PRIME=1:
```sh
run-on-discrete-gpu glxinfo -B
```
For Steam, leave the client on the iGPU and use DRI_PRIME=1 %command% in the individual game's Launch Options. Do not set DRI_PRIME globally. Check the renderer with glxinfo -B and vulkaninfo --summary.

The RX 6500M has 4 GB VRAM. Start with 1080p and medium textures; use FSR/upscaling where available. It does not provide AV1 hardware decode.

## Inventory
```sh
bash shared/scripts/hardware-report.sh
lspci -nnk | grep -A3 -Ei 'VGA|Display|3D'
glxinfo -B
vulkaninfo --summary
```
Confirm both GPUs appear and amdgpu is bound. glxinfo and vulkaninfo are provided by the configured diagnostic packages.

## Firmware and battery
Use Lenovo-supported firmware updates through LVFS only when offered for this model:
```sh
fwupdmgr get-devices
fwupdmgr get-updates
```
Read release notes, connect AC power and follow Lenovo's instructions. Do not interrupt firmware updates.

Inspect supported battery controls before changing charge thresholds:
```sh
grep -H . /sys/class/power_supply/BAT*/{status,capacity,cycle_count,charge_control_start_threshold,charge_control_end_threshold} 2>/dev/null
```
Only use thresholds exposed by the firmware/driver. Do not write arbitrary values to unsupported sysfs nodes.

## Suspend, inputs and peripherals
Test suspend/resume, Wi-Fi, audio, external displays, USB-C docks, touchscreen and fingerprint reader (if present). Do not force a sleep mode or add kernel parameters until the currently supported mode is inspected with cat /sys/power/mem_sleep.
