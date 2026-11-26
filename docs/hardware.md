# ThinkPad Z16 Gen 1 — hardware profile

This configuration targets the following confirmed configuration:
- **CPU:** AMD Ryzen 9 PRO 6950H (8 cores / 16 threads).
- **Integrated GPU:** AMD Radeon 680M (RDNA 2, part of the Ryzen 6000 APU).
- **Discrete GPU:** AMD Radeon RX 6500M (RDNA 2, 4 GB GDDR6, nominal GPU power up to 50 W).
- **Memory:** 32 GB system RAM.

The Z16 Gen 1 was sold in multiple combinations. Verify that the machine reports both GPUs and the exact model before applying hardware-specific changes.

## Graphics stack and hybrid behavior

Use the in-kernel **amdgpu** kernel driver with Mesa **RADV** for Vulkan. This is the preferred open-source AMD gaming path on Fedora. Do not install NVIDIA drivers. Do not add AMDGPU-PRO or AMDVLK by default; the standard Mesa stack is the intended baseline.

- The Radeon 680M iGPU is the efficient default for Hyprland, Waybar, browsers, video playback and desktop compositing.
- The RX 6500M dGPU is the higher-power game renderer. Launch demanding games on it explicitly rather than forcing the entire desktop onto it.
- 32-bit Mesa/Vulkan support is required for older game components and is included in the Fedora host package list.
- The RX 6500M has 4 GB dedicated VRAM. Start with 1080p, medium textures, and use FSR/upscaling where a game offers it. Avoid assuming ultra textures or high-resolution texture packs will fit.
- The RX 6500M does not support AV1 decode; use H.264/HEVC hardware decode where supported.

The shared helper is installed as **run-on-discrete-gpu**. Example:
~~~sh
run-on-discrete-gpu glxinfo -B
run-on-discrete-gpu steam
~~~
For Steam, it is usually better to leave Steam itself on the iGPU and set this per demanding game in Properties -> Launch Options:
~~~sh
DRI_PRIME=1 %command%
~~~
For Lutris/Heroic, set DRI_PRIME=1 in that game's environment variables or launch it with run-on-discrete-gpu followed by the game command. Mesa uses this variable to select the non-default GPU. Check the actual renderer with glxinfo -B or vulkaninfo --summary; GPU numbering can vary by machine and driver.

Do not set DRI_PRIME=1 globally in Hyprland or shell startup: that would keep the discrete GPU active for everyday desktop work and waste battery.

## CPU, memory and longevity

The Ryzen 9 PRO 6950H is an 8-core / 16-thread 45 W class processor. Keep the normal kernel scheduler and AMD power management defaults. Do not add CPU governor forcing, aggressive undervolting, unofficial kernels or fixed GPU clocks as generic performance tweaks.

32 GB RAM is ample for the desktop, game launchers and most games. Keep a reasonable amount of SSD space free for shader caches and game updates. Avoid tuning swappiness or zram without observing real memory pressure first.

## Inventory first

Run:
~~~sh
bash shared/scripts/hardware-report.sh
lspci -nnk | grep -A3 -Ei 'VGA|Display|3D'
glxinfo -B
vulkaninfo --summary
~~~
Install mesa-demos (or the Fedora equivalent) for glxinfo. Confirm that the system lists both Radeon GPUs and that amdgpu is the bound kernel driver.

## Firmware

Use Lenovo-supported UEFI updates through LVFS when the device is listed:
~~~sh
fwupdmgr get-devices
fwupdmgr get-updates
~~~
Read release notes, connect AC power, and follow Lenovo's instructions. Do not interrupt firmware updates. Keep Secure Boot enabled if your boot chain supports it.

## Battery health

Check charge thresholds support before setting them:
~~~sh
ls /sys/class/power_supply/
grep -H . /sys/class/power_supply/BAT*/{status,capacity,cycle_count,charge_control_start_threshold,charge_control_end_threshold} 2>/dev/null
~~~
A conservative 80% upper threshold can reduce time spent at full charge for a mostly plugged-in laptop, but it is not universally best. Use 75–80% for plugged-in use and charge to 100% before travel when needed. Only use thresholds exposed by the firmware/driver; never write arbitrary values to unsupported sysfs nodes.

## Suspend and resume

Test suspend/resume, Wi-Fi, audio, external displays, USB-C docks and fingerprint reader (if present) before relying on the machine. Do not force a sleep mode or add mem_sleep_default until the currently supported mode is inspected with cat /sys/power/mem_sleep.

## Trackpad and keyboard

Hyprland config enables natural scrolling and tap-to-click. Adjust these in shared/hypr/hyprland.conf if they do not match your preference.
