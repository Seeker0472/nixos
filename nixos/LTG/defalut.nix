{ config, lib, pkgs, modulesPath, sharedConfig, ... }:

{

  # TODO
  imports = [
    ./configuration.nix
    # ./de_kde.nix
    ./connection.nix
    # ./develop.nix
    # ./fonts.nix
    ./programs.nix
  ];
}
