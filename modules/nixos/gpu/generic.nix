{ ... }:

{
  # Vendor-agnostic graphics: enough for a Wayland compositor to run.
  # Replace this with a vendor module (./amd.nix, ./intel.nix, ...) once
  # the machine's GPU is known, to pull in the right drivers / VA-API.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
