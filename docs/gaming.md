# Linux gaming setup — ThinkPad Z16 Gen 1

Target hardware: Ryzen 9 PRO 6950H, Radeon 680M iGPU, Radeon RX 6500M dGPU (4 GB VRAM), 32 GB RAM.

## Recommended launcher lineup
- **Steam** — main PC library, native Linux games and Proton; installed by Fedora/RPM Fusion to use the host graphics stack.
- **Heroic Games Launcher** — Epic, GOG and Amazon Prime Gaming libraries.
- **Lutris** — flexible launcher for Battle.net, EA App, Ubisoft Connect, GOG and custom Wine runners.
- **Prism Launcher** — Minecraft Java instances and modpacks.
- **itch.io** — indie games and game jams.
- **Bottles** — isolated Wine environments for Windows apps and selected launchers.
- **ProtonUp-Qt** — manage GE-Proton and other compatibility tools.
- **Discord** — optional voice/text companion for multiplayer.

The Home Manager profile installs the user-level launchers and compatibility tools. Fedora provides Steam, Mesa/RADV, 32-bit graphics libraries and the host services.

## Steam and Proton
After installing Steam:
1. Sign in and open Settings -> Compatibility.
2. Enable Steam Play for supported titles (and optionally all other titles).
3. Start with the latest stable Proton. Try GE-Proton only when a specific title benefits.
4. For a game-specific override, open Properties -> Compatibility and select a tool version.

## AMD hybrid graphics: select the RX 6500M
The Radeon 680M integrated GPU should handle the desktop and low-power tasks. The RX 6500M should be used for demanding games. Both use the in-kernel amdgpu driver and Mesa RADV; do not install NVIDIA drivers or AMDGPU-PRO for this setup.

The repo installs run-on-discrete-gpu, which launches a command with Mesa's DRI_PRIME=1 selection:
~~~sh
run-on-discrete-gpu glxinfo -B
~~~
For Steam, keep the client on the integrated GPU and use this per-game Launch Option:
~~~sh
DRI_PRIME=1 %command%
~~~
For Heroic/Lutris, set DRI_PRIME=1 in that game's environment variables. Do not set this globally in Hyprland or your shell profile; doing so can keep the dGPU awake and reduce battery life. Confirm the active renderer with glxinfo -B or vulkaninfo --summary.

## Performance expectations
The RX 6500M has 4 GB dedicated GDDR6 VRAM and is a roughly 50 W laptop GPU. Treat it as a 1080p gaming part:
- Start at 1920x1080 with medium textures; reduce texture quality first if VRAM fills.
- Use FSR/upscaling when offered. Avoid high-resolution texture packs and ultra textures by default.
- Cap frame rates to a sustainable value when it reduces heat/noise without harming playability.
- Plug in the Lenovo power adapter for demanding games. Use balanced/performance power profile only while gaming.
- Do not force maximum CPU/GPU clocks, undervolt, overclock, or run a performance daemon constantly.

The 32 GB system RAM is sufficient for a broad desktop/game setup; no custom swap or memory tuning is enabled by default.

## Wine and Windows launchers
Wine + Winetricks run Windows installers/apps outside Steam and add common runtime components to isolated prefixes. Prefer one isolated prefix per game/app. Do not install random DLL packs globally or run installers as root.

## Performance and diagnostics
- GameMode: launch a compatible game with gamemoderun %command% to request temporary performance tuning.
- MangoHud: enable per game with mangohud %command%; use GOverlay to configure its display.
- Gamescope: optional per-game wrapper for scaling/fullscreen, e.g. gamescope -f -- %command%.
- Vulkan diagnostics: vulkaninfo --summary.
- OpenGL renderer: glxinfo -B.

Keep overlays off by default and avoid permanent performance tweaks. Higher power modes increase heat, fan noise and battery drain; use them only while plugged in or when needed.

## Anti-cheat limits
Linux compatibility is decided game-by-game by the developer/publisher, not by installing a distro package. Easy Anti-Cheat and BattlEye have Proton support paths, but the developer must enable/configure them for that title. Some kernel-level anti-cheat systems and unsupported launchers/DRM do not work on Linux. No Wine, Proton, kernel, or launcher setting can force publisher support.

Before purchasing/installing a multiplayer game, check ProtonDB, Are We Anti-Cheat Yet?, the game's official support page and recent player reports. If a game explicitly blocks Linux, use a supported platform rather than attempting to bypass anti-cheat.

## Legacy NixOS reference
The nixos/ directory contains an older host example and is not used by the Fedora + standalone Home Manager root flake. Do not run nixos-rebuild on Fedora.

## Longevity
- Keep Mesa and the kernel on normal stable update cadence.
- Avoid unofficial kernels, automatic undervolting, overclocking and background performance daemons.
- Use GameMode only while gaming; don't force maximum performance on battery.
- Keep game libraries on a filesystem with ample free space and maintain regular backups.
