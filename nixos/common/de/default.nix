{ lib, pkgs, sharedConfig, ... }:
{
  imports =
    [
    ]
    ++ (if sharedConfig.desktop_environment == "dwm" then [ ./de_dwm.nix ] else [ ])
    ++ (if sharedConfig.desktop_environment == "kde" then [ ./de_kde.nix ] else [ ]);

  # assert (sharedConfig.desktop_environment == "dwm" || sharedConfig.desktop_environment == "kde");
}



