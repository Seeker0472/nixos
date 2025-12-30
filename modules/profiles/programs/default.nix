{pkgs, ...}: {
  imports = [./kde-connect.nix];
  home-manager.sharedModules = [./home];
}
