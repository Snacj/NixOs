{ pkgs, ... }:

{
  # power
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  powerManagement.enable = true;

  # suspend on lid close
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # compressed swap in ram
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.blueman.enable = true;

  # firmware updates via fwupdmgr
  services.fwupd.enable = true;
}
