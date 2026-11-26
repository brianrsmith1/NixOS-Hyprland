{ config, lib, pkgs, ... }:
let
  z16PowerProfile = pkgs.writeShellScript "z16-power-profile" ''
    set -euo pipefail
    command -v ${pkgs.power-profiles-daemon}/bin/powerprofilesctl >/dev/null 2>&1 || exit 0
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;
  services.power-profiles-daemon.enable = true;
  systemd.services.z16-power-profile = { description = "Select ThinkPad Z16 power profile based on AC connection"; wantedBy = [ "multi-user.target" ]; after = [ "power-profiles-daemon.service" ]; wants = [ "power-profiles-daemon.service" ]; serviceConfig = { Type = "oneshot"; ExecStart = z16PowerProfile; }; };
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", TAG+="systemd", RUN+="/run/current-system/sw/bin/systemctl start --no-block z16-power-profile.service"
  '';
  services.pipewire = { enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true; };
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  programs.hyprland.enable = true;
  xdg.portal = { enable = true; extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ]; };
  users.users.brian = { isNormalUser = true; description = "ThinkPad Z16 user"; extraGroups = [ "wheel" "networkmanager" "video" "audio" ]; shell = pkgs.fish; };
  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [ waybar kitty fuzzel swaynotificationcenter git gh neovim btop fastfetch firefox grim slurp wl-clipboard papirus-icon-theme power-profiles-daemon ];
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
  security.sudo.wheelNeedsPassword = true;
  system.stateVersion = "26.05";
}
