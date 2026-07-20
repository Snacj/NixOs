{ ... }:

{
  # Modules shared by every host. Hardware-, GPU- and role-specific
  # modules (gaming, gpu/*, secure boot, ...) are imported per host.
  imports = [
    ./core.nix
    ./desktop.nix
    ./audio.nix
  ];
}
