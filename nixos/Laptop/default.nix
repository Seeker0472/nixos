{ lib, pkgs, modulesPath, sharedConfig, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./configuration.nix
      ./connection.nix
      # ./develop.nix
      ./hardware-configuration.nix
      ./programs.nix
      # ./fonts.nix
      ./disk.nix
    ];
}
