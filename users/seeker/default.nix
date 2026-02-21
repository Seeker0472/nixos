{ inputs, ... }:
{
  imports = [
  ];

  #FIXME: this should be moved to a common module
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.seeker = import ./home.nix;
  };
}
