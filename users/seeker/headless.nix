{ ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.seeker = {
      imports = [
        ./home.nix
        ./server.nix
      ];
    };
  };
}
