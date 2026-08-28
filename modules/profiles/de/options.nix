# This file should automatically import all folders/files
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.de;
  compositorEnabled = cfg.hyprland.enable || cfg.niri.enable;
in
{
  options.machine.de = {
    hyprland.enable = lib.mkEnableOption "Hyprland, a dynamic tiling Wayland compositor that doesn't sacrifice on looks";
    niri.enable = lib.mkEnableOption "niri, a scrollable-tiling Wayland compositor";
    quickshell.enable = lib.mkEnableOption "Quickshell, the Niri desktop shell and control center";
    waybar.enable = lib.mkEnableOption "Waybar, a highly customizable Wayland bar";
    wofi.enable = lib.mkEnableOption "wofi, a launcher and menu program for Wayland compositors";
    notificationDaemon = lib.mkOption {
      type = lib.types.enum [
        "mako"
        "swaync"
      ];
      default = "swaync";
      description = "Notification daemon used by the Wayland desktop";
    };
    wpaperd.enable = lib.mkEnableOption "wpaperd, a modern wallpaper daemon for Wayland";
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.hyprland.enable && cfg.niri.enable);
          message = "machine.de.hyprland and machine.de.niri cannot be enabled at the same time";
        }
      ];
    }
    (lib.mkIf compositorEnabled {
      machine.de = {
        quickshell.enable = lib.mkDefault cfg.niri.enable;
        waybar.enable = lib.mkDefault (!cfg.niri.enable);
        wofi.enable = lib.mkDefault true;
        wpaperd.enable = lib.mkDefault true;
      };
      environment.systemPackages = with pkgs; [
        libnotify
        acpi
      ];
    })
  ];
}
