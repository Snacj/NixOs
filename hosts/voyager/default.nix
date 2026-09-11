{ ... }:

{
  imports = [
    ../../modules/nixos
    ./hardware-configuration.nix

    ../../modules/nixos/gpu/intel.nix
    ../../modules/nixos/laptop.nix
  ];

  networking.hostName = "voyager";

  # tailscale
  services.tailscale.enable = true;

  # systemd-boot, no secure boot on the laptop
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # release this host was installed against, do not bump
  system.stateVersion = "26.05";
}
