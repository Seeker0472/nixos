{ config, lib, pkgs, ... }:
let
  nvimconfig_path = "${config.home.homeDirectory}/nixos-config/modules/shell/neovim/my_nvim";
in
{
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink nvimconfig_path;
}
