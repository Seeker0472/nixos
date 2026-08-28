{ inputs, ... }:
{
  imports = [
    ./base-cli.nix
    inputs.disko.nixosModules.disko
    inputs.nixvim.nixosModules.nixvim
    ../profiles/programs/mihomo/mihomo.nix
    ../profiles/programs/netbird.nix
    ../profiles/programs/nixvim/default.nix
    ../profiles/system/core/networkmanager.nix
    ../profiles/system/storage/single-disk.nix
  ];
}
