# Fedora + Windows installation and rollback

## Intended disk and OS layout

- Fedora is the sole Linux operating system.
- Windows remains installed as a permanent dual-boot option.
- Nix is installed on Fedora as a package manager; NixOS is not installed.
- This repository does not repartition disks, resize Windows, replace the EFI System Partition, or rewrite the bootloader automatically.

## Before installing Fedora

1. Back up important Windows files and verify that the backup can be read.
2. Confirm Windows boots normally and save any BitLocker recovery key if device encryption is enabled.
3. Create Fedora installation media and verify it boots in UEFI mode.
4. In the Fedora installer, use intended free space or a carefully reviewed partition layout. Do not delete the Windows EFI, recovery or data partitions.
5. Keep the existing Windows Boot Manager entry. Verify both Fedora and Windows boot before changing boot order or firmware settings.

Partitioning is a high-impact manual step. If the disk layout is unclear, stop and inspect it rather than guessing.

## Fedora host setup

1. Install Fedora Workstation (or another Fedora edition with a supported Wayland session).
2. Update Fedora and reboot.
3. Clone the repository and enter its directory:

   ```bash
   git clone https://github.com/brianrsmith1/Fedora-NixOS.git
   cd Fedora-NixOS
   ```

4. Review `fedora/packages.txt` and run the top-level interactive setup:

   ```bash
   less fedora/packages.txt
   bash install.sh
   ```

   The entry point runs `fedora/validate.sh`, then offers separate confirmations for Fedora host packages/RPM Fusion and the Nix daemon. It must be run as your regular user, not with `sudo`.

5. If you prefer manual stages, run:

   ```bash
   bash fedora/validate.sh
   bash fedora/install.sh
   bash fedora/nix-setup.sh
   ```

6. Log out and back in (or reboot) so Nix group membership and service state are active. Verify with `nix --version`.

The Fedora host installer does not configure disk partitions, Windows, EFI entries or the bootloader. It also does not activate Home Manager.

## Home Manager setup

Read [docs/nix-fedora.md](nix-fedora.md) before applying the profile. Confirm your Linux account is `brian`, or edit `home/home.nix` and the flake output attribute to match your actual username.

From the repository root, run the interactive activation helper:

```bash
bash fedora/home-manager-setup.sh
```

The helper checks that you are logged in as `brian`, verifies the Nix daemon, asks you to confirm that conflicting dotfiles are backed up, resolves the flake inputs and runs the standalone activation. If you prefer to activate manually, use:

```bash
nix run home-manager/release-26.05 -- switch --flake .#brian@z16
```

This resolves the selected Home Manager release and builds the standalone profile. Review the activation output before confirming. The first successful run generates `flake.lock`; keep it under version control for reproducible activations. A GitHub Actions workflow now checks Bash syntax, ShellCheck findings and evaluation of the Home Manager activation derivation; this does not replace a real install and hardware test.

The configuration links selected shared Hyprland, Waybar, Kitty, Fish, Starship, Fuzzel, SwayNC and GTK files into your home directory. Back up pre-existing config files before first activation. Do not run `shared/install-dotfiles.sh` after Home Manager takes ownership of those same paths.

## First-boot validation

- Confirm Fedora and Windows remain selectable in the firmware/boot menu.
- Check `hyprctl` version, Waybar, Fuzzel, notifications and lock screen.
- Check audio input/output, Bluetooth, Wi-Fi, brightness keys and touchpad gestures.
- Test suspend/resume, external displays and USB-C docks.
- Run `glxinfo -B` and `vulkaninfo --summary`; verify AMD Mesa sees both GPUs.
- Test Steam and one representative game using the RX 6500M only for that game.
- Test OBS capture/encoding and a representative Kdenlive project before moving important work over.

## Rollback

- **Home Manager:** inspect `home-manager generations` and activate the previous generation using its listed activation path.
- **Dotfiles:** restore backups made before first activation. Avoid manually deleting files while Home Manager still manages them.
- **Fedora:** use the previous kernel from the boot menu or Fedora package rollback guidance if an update causes a regression.
- **Windows:** use the existing Windows Boot Manager entry. Do not delete Windows partitions or EFI files as a Linux troubleshooting shortcut.

Keep a known-good Fedora kernel and Windows boot option until the new setup has passed multiple reboots.
