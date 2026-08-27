{ inputs, ... }:
{
  imports = [
    ./base-system.nix
    inputs.home-manager.nixosModules.home-manager
    ../../users/home-manager.nix
    ../profiles/system/dev/default.nix
  ];
}
