{ ... }:

{
  imports = [
    ../../modules/nixos            # shared base (core, desktop, audio)
    ./hardware-configuration.nix

    ../../modules/nixos/gpu/amd.nix
    ../../modules/nixos/gaming.nix # Steam + gamemode (desktop only)
  ];

  networking.hostName = "oss";

  # Secure boot via lanzaboote (the lanzaboote module is wired in for
  # this host from flake.nix).
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # tailscale
  services.tailscale.enable = true;
}
