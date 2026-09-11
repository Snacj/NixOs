{ ... }:

{
  imports = [
    ../../modules/nixos
    ./hardware-configuration.nix

    ../../modules/nixos/gpu/amd.nix
    ../../modules/nixos/gaming.nix
  ];

  networking.hostName = "oss";

  # secure boot, the lanzaboote module is wired in from flake.nix
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # tailscale
  services.tailscale.enable = true;

  # release this host was installed against, do not bump
  system.stateVersion = "26.05";
}
