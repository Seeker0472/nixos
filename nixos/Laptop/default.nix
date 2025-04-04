{ lib, pkgs, modulesPath, sharedConfig, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./configuration.nix
    ./connection.nix
    ./hardware-configuration.nix
    ./programs.nix
    ./disk.nix
  ];
}
