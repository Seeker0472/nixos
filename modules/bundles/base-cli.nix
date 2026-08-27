{ inputs, ... }:
{
  imports = [
    ./base-system.nix
    inputs.home-manager.nixosModules.home-manager
    ../profiles/system/hardware/users.nix
    ../profiles/system/hardware/user-accounts.nix
  ];
}
