# NixOS + Hyprland — ThinkPad Z16 Gen 1

A standalone NixOS Flake for the Lenovo ThinkPad Z16 Gen 1. It targets the Ryzen 9 PRO 6950H, Radeon 680M integrated GPU, Radeon RX 6500M discrete GPU, 32 GB RAM and OLED touchscreen.

This repository is the **NixOS-only** option. Windows 11 is intended to remain available as a separate dual-boot operating system on the physical laptop.

> **Important:** This is a hardware-targeted configuration, not a one-command installer. The repository does not contain a generated `hardware-configuration.nix` and deliberately does not choose a bootloader for the physical Windows dual-boot installation. Read [docs/installation.md](docs/installation.md) before partitioning or installing. For a disposable virtual machine, follow [docs/vmware-testing.md](docs/vmware-testing.md).

## Choose your installation path

| Goal | Instructions |
|---|---|
| Test the NixOS configuration in VMware | [VMware testing guide](docs/vmware-testing.md) |
| Install on the ThinkPad alongside Windows 11 | [Physical dual-boot installation guide](docs/installation.md#physical-thinkpad-installation-windows-dual-boot) |
| Understand the hardware and GPU setup | [Hardware guide](docs/hardware.md) |
| Power, thermals, OLED and battery | [Power and longevity guide](docs/power-and-longevity.md) |
| Gaming and hybrid graphics | [Gaming guide](docs/gaming.md) |

## What this configuration provides

- Hyprland, SDDM, Waybar, Kitty, Fuzzel and SwayNC.
- AMDGPU firmware, Mesa graphics and Vulkan support.
- PipeWire audio, Bluetooth, NetworkManager, polkit and XDG desktop portals.
- Power Profiles Daemon with AC/battery profile selection.
- A Fish-based shell environment and common command-line tools.
- A discrete-GPU launcher using `DRI_PRIME=1` for individual applications.

## Hardware strategy

- Radeon 680M is the default desktop GPU.
- Radeon RX 6500M is selected per application with `run-on-discrete-gpu` or `DRI_PRIME=1`.
- On AC, request Performance when the platform exposes it; otherwise use Balanced.
- On battery, request Power Saver when available; otherwise use Balanced.
- Use moderate OLED brightness, screen blanking and a dark graphite theme. A dark theme alone does not prevent burn-in.
- No speculative undervolting, fixed clocks, fan curves or firmware modifications.

The Z16 Gen 1 shipped in multiple configurations. Confirm the actual hardware before relying on these assumptions.

## Before you install

1. Back up important files.
2. On the physical laptop, confirm Windows boots and save the BitLocker/device-encryption recovery key if encryption is enabled.
3. Use NixOS 26.05 installation media to match the pinned `nixos-26.05` nixpkgs input and `system.stateVersion = "26.05"`.
4. Generate your own `hardware-configuration.nix` from the target system. Never reuse another machine's hardware file.
5. Review the EFI System Partition and bootloader plan before installing alongside Windows. Never format the Windows EFI partition or guess partition names.

## Repository layout

- `flake.nix` — NixOS Flake outputs `.#z16` and the CI-only `.#z16-ci` evaluation profile.
- `flake.lock` — pins the exact nixpkgs revision.
- `configuration.nix` — system, desktop, hardware, power and package configuration.
- `shared/` — Hyprland, Waybar, Kitty, Fish, Fuzzel, SwayNC and helper scripts.
- `docs/` — installation, VMware, hardware, gaming and power guidance.

## Install the user desktop configuration

After NixOS has booted and you have logged into the normal account, clone this repository into your home directory and run:

```bash
mkdir -p ~/src
git clone https://github.com/brianrsmith1/NixOS-Hyprland.git ~/src/NixOS-Hyprland
cd ~/src/NixOS-Hyprland
bash shared/install-dotfiles.sh
```

The script backs up existing non-symlink config directories with a timestamp suffix, then links the repository's Hyprland, Waybar, Kitty, Fish, Fuzzel, SwayNC and related settings. It also installs `run-on-discrete-gpu` under `~/.local/bin`. Keep the repository in place after linking because the symlinks point into it. Ensure `~/.local/bin` is on your PATH.

## Validation status

GitHub Actions parses the Nix expressions and evaluates the full NixOS configuration using a CI-only sample hardware file and temporary systemd-boot settings. This checks NixOS module and package evaluation; it does **not** prove that the system has been installed, that the full closure builds, or that the configuration works on a physical Z16.

After installation, test suspend/resume, Wi-Fi, audio, brightness controls, touchscreen, external displays, GPU selection, charger events and battery runtime before choosing it as your daily driver.
