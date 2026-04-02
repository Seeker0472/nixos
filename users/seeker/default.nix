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
    users.seeker = {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.zen-browser.homeModules.beta
        inputs.nixvim.homeModules.nixvim
        ../../modules/home
        ./home.nix
      ];
    };
  };
}
