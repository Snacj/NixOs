{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, ... }@inputs:
    let
      mkHost = { hostName, extraModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs hostName; };
          modules = [
            ./hosts/${hostName}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              # hostName reaches every home module, so home config can be
              # made host-aware (see home/).
              home-manager.extraSpecialArgs = { inherit hostName inputs; };
              home-manager.users.snacj = import ./home/home.nix;
            }
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        # Desktop: AMD GPU, Steam, secure boot.
        oss = mkHost {
          hostName = "oss";
          extraModules = [ lanzaboote.nixosModules.lanzaboote ];
        };

        # Laptop: generic GPU, no Steam, plain systemd-boot.
        citadel = mkHost {
          hostName = "citadel";
        };
      };
    };
}
