{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./configuration.nix
      ./connection.nix
      ./desktopenv.nix
      ./develop.nix
      ./hardware-configuration.nix
      ./programs.nix
      ./fonts.nix
    ];

}
