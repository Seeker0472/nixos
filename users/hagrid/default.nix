{ ... }:
{
  imports = [ ../home-manager.nix ];
  home-manager.users.hagrid.imports = [ ./home.nix ];
}
