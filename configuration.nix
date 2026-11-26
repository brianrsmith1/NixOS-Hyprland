{ config, lib, pkgs, ... }:
let
  z16PowerProfile = pkgs.writeShellScript "z16-power-profile" ''
    set -euo pipefail
    on_ac=0
    for supply in /sys/class/power_supply/*; do
      [[ -r "$supply/type" && -r "$supply/online" ]] || continue
      [[ "$(cat "$supply/type")" == "Mains" ]] || continue
      if [[ "$(cat "$supply/online")" == "1" ]]; then on_ac=1; break; fi
    done
    available="$(${pkgs.power-profiles-daemon}/bin/powerprofilesctl list 2>/dev/null || true)"
    if (( on_ac )); then
      if grep -qi performance <<<"$available"; then ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance; else ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced; fi
    else
      if grep -qi power-saver <<<"$available"; then ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver; else ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced; fi
    fi
  '';
in
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "z16";
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Deliberately no boot.loader configuration: review the existing Windows EFI/ESP layout
  # and choose a bootloader setup that preserves Windows Boot Manager before installing.

  networking.networkmanager.enable = true;
  services.power-profiles-daemon.enable = true;
  systemd.services.z16-power-profile = {
    description = "Select ThinkPad Z16 power profile based on AC connection";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    wants = [ "power-profiles-daemon.service" ];
    serviceConfig = { Type = "oneshot"; ExecStart = z16PowerProfile; };
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", TAG+="systemd", RUN+="/run/current-system/sw/bin/systemctl start --no-block z16-power-profile.service"
  '';

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.dbus.enable = true;
  services.blueman.enable = true;
  services.fwupd.enable = true;
  services.upower.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.hyprland.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  users.users.brian = {
    isNormalUser = true;
    description = "ThinkPad Z16 user";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    waybar kitty fuzzel swaynotificationcenter hyprlock hypridle
    starship zoxide fzf ripgrep fd bat eza
    thunar thunar-archive-plugin file-roller
    polkit_gnome networkmanagerapplet blueman pavucontrol
    brightnessctl playerctl wl-clipboard cliphist grim slurp swappy swww
    udiskie gvfs wlogout nwg-look
    git gh neovim btop fastfetch firefox
    papirus-icon-theme nerd-fonts.jetbrains-mono noto-fonts-emoji
    power-profiles-daemon fwupd
    pciutils usbutils lshw inxi lm_sensors smartmontools nvme-cli
    mesa-demos vulkan-tools libva-utils
  ];

  security.sudo.wheelNeedsPassword = true;
  system.stateVersion = "26.05";
}
