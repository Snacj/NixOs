{ ... }:

{
  # amd gpu; 32-bit for steam
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.initrd.enable = true;
}
