{ inputs, ... }:
{
  imports = [
    ./base-cli.nix
    ../profiles/system/core/networkmanager.nix
    ../profiles/system/dev/default.nix
    inputs.nixvim.nixosModules.nixvim
    ../profiles/programs/nixvim/default.nix
  ];
}
