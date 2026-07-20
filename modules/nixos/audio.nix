{ config, pkgs, ... }:

{
  # PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Real-time scheduling for low-latency audio
  security.rtkit.enable = true;
}
