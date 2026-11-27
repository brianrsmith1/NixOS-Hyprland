# NixOS installation — ThinkPad Z16 Gen 1 and VMware

This guide covers two different targets:

- **VMware:** a disposable virtual disk that can be erased completely.
- **Physical ThinkPad:** an existing Windows 11 installation that must be preserved.

Do not use the VMware partitioning commands on the physical laptop.

## Requirements

- NixOS 26.05 installation media, booted in UEFI mode.
- Internet access from the installer.
- A keyboard and enough disk space for NixOS.
- This repository cloned into the live environment.
- For physical dual boot: a verified Windows backup and the BitLocker/device-encryption recovery key, if enabled.

The flake pins `nixpkgs/nixos-26.05` and `configuration.nix` sets `system.stateVersion = "26.05"`. Use matching installation media for this configuration. Do not change `system.stateVersion` casually; it records the initial NixOS installation compatibility baseline.

## 1. Boot the installer and get the repository

Boot the NixOS installer in **UEFI** mode. Connect to the network, then open a terminal.

If Git is not available in the live environment:

```bash
nix-shell -p git
```

Clone the repository:

```bash
git clone https://github.com/brianrsmith1/NixOS-Hyprland.git
cd NixOS-Hyprland
```

Enable flakes for the commands in this guide:

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
```

For commands run through sudo, pass the setting explicitly as shown later.

## 2. VMware installation (the virtual disk may be erased)

Use this path only when the selected disk is the dedicated VMware virtual disk. These commands create a new GPT partition table and erase the selected disk.

Suggested VM settings:
- Guest type: Linux / NixOS (or Other Linux 64-bit if NixOS is not listed).
- Firmware: UEFI.
- Virtual disk: 100 GB or larger.
- Memory: 8–12 GB; 4 vCPUs is a reasonable starting point.
- Network: NAT, connected at power-on.

Identify the disk:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MODEL,MOUNTPOINTS
```

On a typical VMware SCSI VM the disk may be `/dev/sda`; NVMe virtual disks may use another name. **Do not assume the example device name is correct.** Confirm the model and size before proceeding.

For the dedicated VM disk only, replace `/dev/sda` below with the device you positively identified:

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

Check the result before continuing:

```bash
lsblk -f
findmnt /mnt
findmnt /mnt/boot
```

Add this bootloader configuration to `configuration.nix` (inside the outer attribute set):

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.loader.systemd-boot.configurationLimit = 5;
```

This VM-only path uses the full virtual disk. Do not copy its `parted` or `mkfs` commands to the physical ThinkPad.

Continue at [Generate the hardware configuration](#3-generate-the-machine-specific-hardware-configuration).

## 3. Physical ThinkPad installation (Windows dual boot)

### Prepare Windows first

1. Boot Windows and verify it works.
2. Back up important files and create/review Windows recovery media.
3. If BitLocker/device encryption is enabled, save the recovery key somewhere outside the laptop. Suspend protection before changing the partition layout, and follow Microsoft's guidance for resuming it after the boot configuration is stable.
4. Disable Windows Fast Startup/hibernation before sharing disks with Linux. In an elevated Windows terminal, use `powercfg /h off` if you intend to disable hibernation as well.
5. Use Windows Disk Management to shrink the Windows NTFS volume and leave the required space **unallocated**. Do not format that space in Windows.
6. Reboot Windows once and confirm it still starts normally.

### Inspect the disk from the NixOS installer

Boot the NixOS installer in UEFI mode and inspect the disk:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,PARTTYPENAME,PARTLABEL,UUID,MOUNTPOINTS
sudo parted -l
```

Identify, by size and filesystem, all of the following:
- The Windows NTFS partitions.
- The existing EFI System Partition (ESP), normally FAT32.
- Windows recovery partitions.
- The unallocated space created for NixOS.

**Stop if you cannot identify every partition confidently.** Do not delete, format, resize or relabel any Windows, recovery or EFI partition. This repository does not automate physical partitioning.

Create a Linux root partition only in the unallocated space. Choose a filesystem and mount layout deliberately. For a simple ext4 root, after creating the new Linux partition, format only that newly created partition and mount it at `/mnt`. Do not run `mkfs` against the Windows ESP or any Windows partition.

### EFI and bootloader decision — required before installation

The supplied `configuration.nix` intentionally does not enable a bootloader. This is a safety measure, not an omission to ignore.

The straightforward systemd-boot arrangement requires:
- UEFI boot.
- The ESP mounted at `/boot` in the target installation.
- Enough free space on that ESP for NixOS kernels and initrds. About 1 GiB is recommended for this configuration; many existing Windows ESPs are much smaller.
- The existing Windows EFI files left intact.

Mount the existing Windows ESP at `/mnt/boot` **without formatting it** only if you have verified that it has sufficient free space and are deliberately sharing it. Then add this to `configuration.nix`:

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.loader.systemd-boot.configurationLimit = 5;
```

If the existing ESP is too small, nearly full, has an unclear layout, or you are unsure how to preserve Windows Boot Manager, **stop before installation** and get the partition layout reviewed. Do not resize or reformat the ESP as a guess. A separate ESP or a different bootloader arrangement needs a deliberate plan for both operating systems.

After mounting the new NixOS root at `/mnt` and the reviewed ESP at `/mnt/boot`, verify:

```bash
lsblk -f
findmnt /mnt
findmnt /mnt/boot
df -h /mnt/boot
ls -la /mnt/boot/EFI
```

The Windows EFI directory should still be present if Windows uses this ESP. Do not proceed if the mount points or contents are unexpected.

## 4. Generate the machine-specific hardware configuration

This repository imports `./hardware-configuration.nix`. That file is intentionally not committed because it contains machine-specific filesystem UUIDs and mount points.

With the intended target filesystems mounted under `/mnt`, run:

```bash
sudo nixos-generate-config --root /mnt
```

Copy the generated hardware file into the repository root, beside `configuration.nix`:

```bash
sudo cp /mnt/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
sudo chown "$(id -u):$(id -g)" ./hardware-configuration.nix
```

Review the file:

```bash
sed -n '1,240p' hardware-configuration.nix
```

Confirm that the root filesystem and `/boot` UUIDs match the partitions you mounted. For the physical install, make sure the ESP mount points to the intended existing ESP and is not marked for formatting. Do not copy a hardware file from a VM or another computer.

## 5. Review the user account and boot settings

The default account in `configuration.nix` is `brian`. If you want another username, edit the `users.users.brian` attribute and the corresponding post-install instructions before evaluating.

For the VMware path, use the systemd-boot snippet in the VMware section.

For the physical path, use a bootloader configuration only after completing the EFI review above. The repo intentionally does not guess this for you.

## 6. Evaluate and install

From the repository root, with the target mounted and `hardware-configuration.nix` in place:

```bash
nix flake check --show-trace
nix eval .#nixosConfigurations.z16.config.system.build.toplevel.drvPath
```

If evaluation succeeds, install:

```bash
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-install --flake .#z16
```

Set the root password when prompted. Read all prompts and errors. Do not force the installation if NixOS reports missing mounts, an absent bootloader configuration, an EFI problem or a filesystem error.

## 7. First boot and create the normal user's password

Remove the installer media and reboot. Select the NixOS entry from the firmware boot menu if needed. On the physical laptop, verify that **Windows Boot Manager** is still available as a separate boot option.

The configuration creates the normal user `brian` but does not set a reusable password in the repository. At the SDDM login screen, switch to a text console (for example, Ctrl+Alt+F3), log in as `root` with the root password set during installation, and run:

```bash
passwd brian
```

Return to the graphical login screen (often Ctrl+Alt+F1 or Ctrl+Alt+F2; the exact VT varies), select the Hyprland session if prompted, and log in as `brian`.

If SDDM does not appear, use a text console and inspect:

```bash
systemctl status display-manager --no-pager
journalctl -b -u display-manager --no-pager
```

## 8. Install the user dotfiles

After logging in as `brian`:

```bash
mkdir -p ~/src
git clone https://github.com/brianrsmith1/NixOS-Hyprland.git ~/src/NixOS-Hyprland
cd ~/src/NixOS-Hyprland
bash shared/install-dotfiles.sh
```

Keep the repository in place because the configuration symlinks point into it. Existing non-symlink config directories are moved to timestamped backup names. Review those backups before deleting anything. Ensure `~/.local/bin` is on PATH.

## 9. First-boot hardware checklist

Run these checks:

```bash
bash ~/src/NixOS-Hyprland/shared/scripts/hardware-report.sh
lspci -nnk | grep -A3 -Ei 'VGA|Display|3D'
glxinfo -B
vulkaninfo --summary
powerprofilesctl list
powerprofilesctl get
```

Then test:
- Wi-Fi, Bluetooth, speakers, microphone and headset.
- Brightness keys, keyboard backlight, touchpad and touchscreen.
- Suspend/resume and lid close/open behavior.
- External displays, USB-C docks and charging.
- Radeon 680M as the desktop renderer and RX 6500M when explicitly selected.
- AC/battery profile changes and real battery discharge rate.

Do not add kernel parameters, undervolts, charge thresholds or firmware changes until you have verified that the hardware exposes and supports them.

## Recovery and Windows preservation

Keep the NixOS installer USB and Windows recovery key available. If the NixOS boot entry fails, use the firmware's one-time boot menu and select Windows Boot Manager. Do not delete EFI files or rewrite the partition table as a troubleshooting shortcut. If Windows disappears from the firmware menu, stop and inspect the EFI contents and firmware entries before attempting repair.
