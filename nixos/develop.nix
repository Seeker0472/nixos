###################################################################
#  development configuration
###################################################################

{ config, lib, pkgs, modulesPath, ... }:

{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
      pkgs.llvmPackages_latest.llvm
            pkgs.ncurses
            pkgs.readline
            pkgs.SDL2
            pkgs.SDL2_image
            pkgs.SDL2_ttf
            pkgs.libz
    # Add any missing dynamic libraries for unpackaged programs

    # here, NOT in environment.systemPackages
  ];
}


