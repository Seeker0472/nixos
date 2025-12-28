{ config, lib, pkgs, ... }:
let
  nvimconfig_path =
    "${config.home.homeDirectory}/nixos-config/modules/shell/neovim";
  scripts_path =
    "${config.home.homeDirectory}/nixos-config/modules/shell/scripts";
in {
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink nvimconfig_path;
  home.file."scripts".source =
    config.lib.file.mkOutOfStoreSymlink scripts_path;
}
