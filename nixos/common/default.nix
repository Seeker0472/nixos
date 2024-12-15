{ lib, pkgs, ... }:
{
  imports =
    [
      ./de
      ./develop.nix
      ./fonts.nix
      ./common_conf.nix
    ];
}
