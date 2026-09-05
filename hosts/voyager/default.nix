{ ... }:

{
  imports = [
    ../../modules/nixos            # shared base (core, desktop, audio)
    ./hardware-configuration.nix

    # Laptop GPU is not yet decided. This gives working graphics for the
    # Wayland session; swap it for a vendor module once known, e.g.:
    #   ../../modules/nixos/gpu/amd.nix
    #   ../../modules/nixos/gpu/intel.nix
    ../../modules/nixos/gpu/generic.nix

    # Deliberately NOT imported on the laptop:
    #   - ../../modules/nixos/gaming.nix   (no Steam)
    #   - lanzaboote / secure boot         (see boot loader below)
  ];

  networking.hostName = "voyager";

  # Plain systemd-boot (no lanzaboote / secure boot on the laptop).
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
