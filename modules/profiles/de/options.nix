# This file should automatically import all folders/files
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.de;
  custom_cursor = {
    name = "Bibata-Modern-Amber";
    package = pkgs.bibata-cursors;
    size = 32;
  };
in
{
  options.machine.de = {
    hyprland.enable = lib.mkEnableOption "Hyprland, a dynamic tiling Wayland compositor that doesn't sacrifice on looks";
    waybar.enable = lib.mkEnableOption "Waybar, a highly customizable Wayland bar";
    wofi.enable = lib.mkEnableOption "wofi, a launcher and menu program for Wayland compositors";
    mako.enable = lib.mkEnableOption "mako, a lightweight notification daemon for Wayland";
    wpaperd.enable = lib.mkEnableOption "wpaperd, a modern wallpaper daemon for Wayland";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.hyprland.enable {
      machine.de = {
        waybar.enable = lib.mkDefault true;
        wofi.enable = lib.mkDefault true;
        mako.enable = lib.mkDefault true;
        wpaperd.enable = lib.mkDefault true;
      };
      environment.systemPackages = with pkgs; [
        libnotify
        acpi
      ];
    })
  ];
}
