{ pkgs, nur, winapps,  ... }:

{
  #imports = [ ] ++ (if sharedConfig.desktop_environment == "hyperland" then
  #  [ ./hyperland.nix ]
  #else
  #  [ ]);
  imports = [./hyprland.nix];
}
