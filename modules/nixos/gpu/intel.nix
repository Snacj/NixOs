{ pkgs, ... }:

{
  # intel gpu with va-api, otherwise video decode runs on the cpu
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # vainfo
  environment.systemPackages = [ pkgs.libva-utils ];
}
