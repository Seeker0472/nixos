{ inputs, ... }:
{
  imports = [
    ./base-system.nix
    inputs.disko.nixosModules.disko
    ../profiles/system/storage/single-disk.nix
  ];
}
