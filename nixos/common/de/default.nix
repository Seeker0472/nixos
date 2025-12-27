{ lib, pkgs,  ... }: {
  #imports = [ ] ++ (if sharedConfig.desktop_environment == "dwm" then
  #  [ ./de_dwm.nix ]
  #else
  #  [ ]) ++ (if sharedConfig.desktop_environment == "hyperland" then
  #    [ ./de_hyperland.nix ]
  #  else
  #    [ ]) ++ (if sharedConfig.desktop_environment == "kde" then
  #      [ ./de_kde.nix ]
  #    else
  #      [ ]);
  imports = [./de_hyprland.nix];

  # assert (sharedConfig.desktop_environment == "dwm" || sharedConfig.desktop_environment == "kde");
}
