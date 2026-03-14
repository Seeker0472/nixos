{ inputs, ... }:
{
  imports = [
  ];

  #FIXME: this should be moved to a common module
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
  programs.dconf.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.seeker = import ./home.nix;
  };
}
