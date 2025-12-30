{pkgs, ...}: {
  imports = [./kde-connect.nix ./zed.nix];
  home-manager.sharedModules = [./home];
}
