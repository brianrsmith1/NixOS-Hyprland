{
  description = "Standalone NixOS + Hyprland for ThinkPad Z16 Gen 1";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.z16 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
    # CI-only evaluation profile. It does not change the real z16 configuration
    # or prescribe a bootloader for the Windows dual-boot installation.
    nixosConfigurations.z16-ci = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ({ ... }: {
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = false;
        })
      ];
    };
  };
}
