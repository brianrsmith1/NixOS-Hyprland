# Linux gaming — NixOS on ThinkPad Z16 Gen 1

Target hardware: Ryzen 9 PRO 6950H, Radeon 680M iGPU, Radeon RX 6500M dGPU (4 GB VRAM), 32 GB RAM.

The NixOS base configuration focuses on the operating system and desktop, not a complete gaming application bundle. Add Steam and other launchers through NixOS options or environment.systemPackages after reviewing unfree licensing and package availability for the selected nixpkgs revision.

## AMD hybrid graphics
Use Radeon 680M for the desktop and low-power tasks. Use RX 6500M selectively for demanding games. Both GPUs use the in-kernel amdgpu driver and Mesa RADV.

For Steam, use a per-game Launch Option:
```sh
DRI_PRIME=1 %command%
```
For other launchers, set DRI_PRIME=1 in that game's environment or run it with run-on-discrete-gpu. Do not set this globally; the dGPU can increase idle power use.

## Performance expectations
The RX 6500M has 4 GB dedicated VRAM. Start at 1920x1080 with medium textures, use FSR/upscaling when available and avoid high-resolution texture packs. Plug in for demanding games. Higher power modes increase heat, fan noise and battery drain.

## Compatibility
Proton and Wine support is title-specific. Easy Anti-Cheat and BattlEye work only when the individual publisher enables/configures support for that title. Check ProtonDB, Are We Anti-Cheat Yet? and recent player reports before purchasing. No local configuration can force publisher support.

## Diagnostics
Use glxinfo -B and vulkaninfo --summary to verify the active renderer. MangoHud, GameMode and Gamescope are optional additions; keep overlays off by default and use temporary performance tuning only when needed.
