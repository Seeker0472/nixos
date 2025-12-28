# This file should automatically import all folders/files
{ config, lib, pkgs, ...}:
let
cfg = config.seeker.de;
gui_path_base = "${config.home.homeDirectory}/nixos-config/modules/gui";
wofi_path = "${gui_path_base}/wofi";
wallpaper_path = "${gui_path_base}/wallpaper";
wpaperd_path = "${gui_path_base}/wpaperd";
mako_path = "${gui_path_base}/mako";
custom_cursor = {
  name = "Bibata-Modern-Amber";
  package = pkgs.bibata-cursors;
  size = 32;
};
enabledPackages = []
  ++ lib.lists.optionals cfg.hyprland.enable [pkgs.hyprland-qtutils pkgs.libnotify pkgs.acpi] # Hyprland dependence
  ## this should be packed into nix,too
  ++ lib.lists.optional cfg.wofi.enable pkgs.wofi # app launcher
  ++ lib.lists.optional cfg.wpaperd.enable pkgs.wpaperd; # notification
in
{
  options.seeker.de = {
    hyprland.enable = lib.mkEnableOption "Hyprland, a dynamic tiling Wayland compositor that doesn't sacrifice on looks";
    waybar.enable = lib.mkEnableOption "Waybar, a highly customizable Wayland bar";
    wofi.enable = lib.mkEnableOption "wofi, a launcher and menu program for Wayland compositors";
    mako.enable = lib.mkEnableOption "mako, a lightweight notification daemon for Wayland";
    wpaperd.enable = lib.mkEnableOption "wpaperd, a modern wallpaper daemon for Wayland";
  };
  config = lib.mkMerge [
    {
    seeker.de.waybar.enable = lib.mkDefault cfg.hyprland.enable;
    seeker.de.wofi.enable = lib.mkDefault cfg.hyprland.enable;
    seeker.de.mako.enable = lib.mkDefault cfg.hyprland.enable;
    seeker.de.wpaperd.enable = lib.mkDefault cfg.hyprland.enable;
  }


  ];

  # map files
  home.file.".config/wofi".source =
    config.lib.file.mkOutOfStoreSymlink wofi_path;# Pack & rewite wofi.sh into python
  home.file.".config/mako".source =
    config.lib.file.mkOutOfStoreSymlink mako_path; # Okey
  home.file.".config/wpaperd".source =
    config.lib.file.mkOutOfStoreSymlink wpaperd_path; # Okey
  home.file."Pictures/wallpaper/default".source =
    config.lib.file.mkOutOfStoreSymlink wallpaper_path; # Okey
}
