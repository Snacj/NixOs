{ ... }:

{
  # vendor-agnostic fallback; swap for amd.nix or intel.nix once the gpu is known
  # no enable32Bit here, that is only needed for steam
  hardware.graphics.enable = true;
}
