# ############################################################################
# PLACEHOLDER — regenerate on the laptop before building this host!
#
# Run on the CITADEL machine:
#     sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
# and replace this file with the output (correct filesystem UUIDs, kernel
# modules and CPU microcode for the actual hardware).
#
# The UUIDs below are fake and will NOT boot as-is.
# ############################################################################
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
      fsType = "ext4";
    };
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0000-0000";
      fsType = "vfat";
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # Adjust to the laptop's CPU vendor (amd/intel) after regenerating.
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
