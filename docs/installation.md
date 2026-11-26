# NixOS installation — ThinkPad Z16 Gen 1 with Windows dual boot

This repository configures a standalone NixOS system. It does not install Fedora and does not use Home Manager.

## Before touching partitions
1. Back up important Windows files and verify the backup.
2. Confirm Windows boots. If BitLocker/device encryption is enabled, save the recovery key.
3. Use NixOS 26.05 installation media to match the flake's nixpkgs channel, and boot it in UEFI mode. If you choose another release, update the flake input and system.stateVersion together.
4. Identify the existing Windows EFI System Partition, Windows recovery/data partitions and genuinely unused space. Do not format or delete Windows partitions.
5. If the disk layout is unclear, stop. Do not guess partition device names or filesystem UUIDs.

Partitioning is intentionally not automated by this repository.

## Generate the machine-specific hardware file
Boot the NixOS live environment, partition and mount the intended NixOS filesystems manually, then generate the hardware config for the mounted target. For example, after mounting the target root at /mnt:

```bash
sudo nixos-generate-config --root /mnt
```

Copy the generated /mnt/etc/nixos/hardware-configuration.nix into the root of this cloned repository, beside configuration.nix. Review its filesystem UUIDs and mount points. Do not copy an example from another computer.

## Review bootloader configuration before installation
The supplied configuration.nix intentionally does not configure boot.loader. Merge in a bootloader configuration only after inspecting the actual UEFI/EFI System Partition arrangement and the NixOS installer documentation for the current release. Preserve the Windows Boot Manager files and entry. Do not blindly enable systemd-boot or GRUB with guessed EFI mount paths.

The generated hardware-configuration.nix normally includes target filesystem mount points, but it does not make the bootloader decision for you.

## Evaluate and install
From the NixOS live environment, with target filesystems mounted and the repo available:

```bash
nix flake check --show-trace
nix eval .#nixosConfigurations.z16.config.system.build.toplevel.drvPath
```

Only after evaluation succeeds, bootloader configuration has been reviewed, and target mount layout is correct, run:

```bash
sudo nixos-install --flake .#z16
```

Review every prompt and error. Do not force an install if it reports a missing mount, bootloader or filesystem problem.

## Link the user desktop configuration

After NixOS is installed and you have logged into the new user account, run this from the cloned repository:

```bash
bash shared/install-dotfiles.sh
```

The script backs up existing config directories with a timestamp suffix, links the Hyprland/Waybar/Fish/Kitty/Fuzzel/SwayNC settings, and installs the discrete-GPU helper in ~/.local/bin. Keep the repository in place after linking, since the links point into it.

## First boot
- Confirm both NixOS and Windows Boot Manager remain available.
- Check Wi-Fi, Bluetooth, audio, microphone, brightness keys, touchpad and touchscreen.
- Test suspend/resume, external displays, USB-C docks and charger plug/unplug behavior.
- Run lspci -nnk, glxinfo -B and vulkaninfo --summary; confirm both Radeon GPUs use amdgpu.
- Check powerprofilesctl get after AC/battery transitions.
- Test games and creative applications only after installing the applications you need.

## Recovery
Keep the NixOS installer USB and Windows recovery key available. Preserve a known-good Windows boot option. If the NixOS boot entry fails, use the firmware boot menu and select Windows Boot Manager; do not delete EFI files as a troubleshooting shortcut.
