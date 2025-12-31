# This file should automatically import all folders/files
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.seeker.de;
  custom_cursor = {
    name = "Bibata-Modern-Amber";
    package = pkgs.bibata-cursors;
    size = 32;
  };
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
    (lib.mkIf cfg.hyprland.enable {
      seeker.de = {
        waybar.enable = lib.mkDefault true;
        wofi.enable = lib.mkDefault true;
        mako.enable = lib.mkDefault true;
        wpaperd.enable = lib.mkDefault true;
      };
      environment.systemPackages = with pkgs; [
        libnotify
        acpi
      ];

      home-manager.sharedModules = [
        {
          # home.packages = lib.flatten [
          #   (lib.optional cfg.wpaperd.enable pkgs.wpaperd)
          # ];

          wayland.windowManager.hyprland = {
            enable = true;
            settings.exec-once = [
              "hyprctl setcursor ${custom_cursor.name} ${builtins.toString custom_cursor.size}"
            ];
          };

          home.pointerCursor = {
            inherit (custom_cursor) name package size;
            gtk.enable = true;
            x11.enable = true;
          };

          gtk = {
            enable = true;
            theme = {
              package = pkgs.kdePackages.breeze-gtk;
              name = "Breeze";
            };
            iconTheme = {
              package = pkgs.kdePackages.breeze-icons;
              name = "breeze";
            };
          };

          services.mako.enable = cfg.mako.enable;
        }
      ];
    })
  ];
}
