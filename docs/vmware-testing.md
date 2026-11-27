# VMware testing guide

Use this guide to test the NixOS-Hyprland configuration in a disposable VMware virtual machine before installing it on the ThinkPad.

A VM is useful for checking NixOS installation, Flake evaluation, package availability, services, networking and basic desktop configuration. It does **not** validate the ThinkPad's AMD graphics, OLED, touchscreen, battery behavior, suspend/resume, firmware or hybrid-GPU switching.

## Create the VM

Suggested starting settings:
- Guest OS: Linux, 64-bit (NixOS if listed).
- Firmware: UEFI.
- Virtual disk: 100 GB or larger.
- RAM: 8–12 GB.
- CPU: 4 vCPUs.
- Network: NAT, with Connected and Connect at power on enabled.
- Display: VMware default virtual graphics settings.

Use a separate VM and virtual disk. The installation steps below erase the selected virtual disk.

## Install

Boot the NixOS 26.05 ISO in UEFI mode. Connect the network and open a terminal.

If needed, make Git and partitioning utilities available:

```bash
nix-shell -p git parted dosfstools e2fsprogs
```

Clone the repository:

```bash
git clone https://github.com/brianrsmith1/NixOS-Hyprland.git
cd NixOS-Hyprland
export NIX_CONFIG="experimental-features = nix-command flakes"
```

Identify the virtual disk carefully:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MODEL,MOUNTPOINTS
```

A VMware SCSI disk is often `/dev/sda`, but confirm the actual device. The next commands erase the selected disk. Use them only on the dedicated virtual disk, never on a physical Windows disk.

Replace `/dev/sda` if the VM reports a different disk:

```bash
sudo parted /dev/sda --script mklabel gpt
sudo parted /dev/sda --script mkpart ESP fat32 1MiB 1025MiB
sudo parted /dev/sda --script set 1 esp on
sudo parted /dev/sda --script mkpart NixOS ext4 1025MiB 100%
sudo mkfs.fat -F 32 /dev/sda1
sudo mkfs.ext4 -L nixos /dev/sda2
sudo mount /dev/sda2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/sda1 /mnt/boot
```

Confirm the mounts:

```bash
lsblk -f
findmnt /mnt
findmnt /mnt/boot
```

## Generate hardware configuration and enable the VM bootloader

Generate the hardware file for this VM:

```bash
sudo nixos-generate-config --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
sudo chown "$(id -u):$(id -g)" ./hardware-configuration.nix
```

Add these lines inside the outer attribute set in `configuration.nix`:

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.loader.systemd-boot.configurationLimit = 5;
```

The repository intentionally leaves the bootloader undefined for the physical Windows dual-boot target. In this VM, the entire virtual disk is dedicated to NixOS, so systemd-boot can safely use the new virtual ESP.

## Evaluate and install

```bash
nix flake check --show-trace
nix eval .#nixosConfigurations.z16.config.system.build.toplevel.drvPath
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-install --flake .#z16
```

Set the root password when prompted. Remove the ISO and reboot.

## First login

The default normal account is `brian`. At the SDDM login screen, switch to a text console (for example, Ctrl+Alt+F3), log in as root, and set the user's password:

```bash
passwd brian
```

Return to the graphical login screen and log in as `brian`.

Clone the repository into the normal user's home directory and install the desktop configuration:

```bash
mkdir -p ~/src
git clone https://github.com/brianrsmith1/NixOS-Hyprland.git ~/src/NixOS-Hyprland
cd ~/src/NixOS-Hyprland
bash shared/install-dotfiles.sh
```

## What this VM test can and cannot prove

Can test:
- NixOS installer flow and boot.
- Flake evaluation and package resolution.
- System services, networking and user setup.
- SDDM session registration and basic desktop startup.
- Dotfile linking and shell configuration.

Cannot reliably test:
- Radeon 680M/RX 6500M performance or PRIME offload.
- ThinkPad OLED behavior, touchscreen, keyboard hotkeys or fingerprint reader.
- Real battery telemetry, charging thresholds, power profiles or battery runtime.
- Physical suspend/resume, firmware updates, USB-C docks or external monitor behavior.

VMware exposes a virtual graphics adapter rather than the ThinkPad's AMD GPUs. If Hyprland fails in VMware, record the error and continue evaluating the NixOS system/configuration; do not conclude that the physical AMD graphics setup will fail. Validate the desktop on the ThinkPad using a live USB before committing to an internal-disk installation.
