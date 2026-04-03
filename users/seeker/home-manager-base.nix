{ inputs, ... }:
let
  hmShared = import ../../outputs/common/home-manager-shared.nix { inherit inputs; };
in
{
  # Keep desktop portal paths available when Home Manager installs user packages via NixOS.
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
  programs.dconf.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = hmShared.extraSpecialArgs;
  };
}
