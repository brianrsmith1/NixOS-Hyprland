# NixOS Hyprland — ThinkPad Z16 Gen 1

Standalone NixOS + Hyprland Flake for the Lenovo ThinkPad Z16 Gen 1: Ryzen 9 PRO 6950H, Radeon 680M iGPU, Radeon RX 6500M dGPU (4 GB VRAM), 32 GB RAM, 1 TB SSD and OLED touchscreen.

## Scope
This is the NixOS-only project. It does not depend on Fedora or Home Manager. The NixOS system configuration installs Hyprland, Waybar, core desktop tools, AMD graphics support, audio, networking and power-profile integration. Windows 11 is intended to remain a permanent dual-boot option.

## Desktop workflow
Muted Catppuccin Mocha/graphite styling, slim Waybar, Kitty, Fuzzel and SwayNC. Workspaces: 1 Main, 2 Terminal/Development, 3 Creative, 4 Communication, 5 Gaming. Super+1..5 switches workspaces; Super+Shift+1..5 moves the focused window.

## Hardware strategy
- Radeon 680M is the default desktop GPU.
- RX 6500M is selected for individual games/apps with DRI_PRIME=1.
- AC: Performance when available, otherwise Balanced. Battery: Power Saver when available, otherwise Balanced.
- OLED: moderate battery brightness, screen blanking and dark graphite theme. Dark UI alone does not prevent burn-in.
- No speculative undervolting, fixed clocks or firmware tweaks.

## Important install warning
The flake pins nixpkgs to the NixOS 26.05 channel. Use matching 26.05 installation media, or update the flake input and system.stateVersion together if you intentionally target a different release. The default account in configuration.nix is brian; edit users.users.brian if your Linux username differs. This repository is a configuration starting point, not a tested one-click installer. hardware-configuration.nix is machine-generated and intentionally not included. Generate it from the NixOS live installer and place it beside configuration.nix.

The configuration deliberately does not set a bootloader. Before installing, inspect the existing Windows EFI System Partition and configure a bootloader that preserves Windows Boot Manager. Do not blindly enable or replace EFI boot entries. Follow docs/installation.md carefully. After installation and first login, run bash shared/install-dotfiles.sh from the cloned repository to link the user desktop configuration. Back up existing config directories first.

## Repository layout
- flake.nix — NixOS flake output .#z16.
- configuration.nix — system, desktop, hardware, power and package configuration.
- shared/ — Hyprland, Waybar, Kitty, Fish, Fuzzel, SwayNC and helper scripts.
- docs/ — installation, hardware, gaming and power guidance.

## Build status
No NixOS evaluation/build or physical Z16 test is claimed. Evaluate and build from a NixOS environment after generating hardware-configuration.nix and reviewing bootloader/partition settings. Test suspend/resume, Wi-Fi, audio, external displays, GPU selection, charger events and battery runtime before daily use.
