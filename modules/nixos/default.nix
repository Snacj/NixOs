{ ... }:

{
  # shared by every host; role-specific modules are imported per host
  imports = [
    ./core.nix
    ./desktop.nix
    ./audio.nix
  ];
}
