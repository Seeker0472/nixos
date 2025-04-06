{ config, lib, pkgs, ... }:
let
  gui_path_base = "${config.home.homeDirectory}/nixos-config/modules/gui";
  hyprland_path = "${gui_path_base}/hypr";
  waybar_path = "${gui_path_base}/waybar";
  wofi_path = "${gui_path_base}/wofi";
  wallpaper_path = "${gui_path_base}/wallpaper";
  wpaperd_path = "${gui_path_base}/wpaperd";
  mako_path = "${gui_path_base}/mako";
in {
  home.packages = with pkgs; [
    hyprland-qtutils # Hyprland dependence
    xdg-desktop-portal-hyprland 
    hyprpaper # wallpaper
    wpaperd
    hyprlock # screen-locker
    hyprsunset # warm-color screen (TODO)
    hyprpicker # color picker (TODO)
    hypridle # idle management daemon (TODO screen-lock after wakeup)
    bluetuith # bluetooth tui
    wofi # app launcher
    mako # notification
    hyprpolkitagent # polkit agent (root permission)
    pavucontrol
    networkmanager # tui network
    libnotify # notify-send
    acpi # battery
    brightnessctl
    grim
    slurp
  ];
  # map files
  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink hyprland_path;
  home.file.".config/waybar".source =
    config.lib.file.mkOutOfStoreSymlink waybar_path;
  home.file.".config/wofi".source =
    config.lib.file.mkOutOfStoreSymlink wofi_path;
  home.file.".config/mako".source =
    config.lib.file.mkOutOfStoreSymlink mako_path;
  home.file.".config/wpaperd".source =
    config.lib.file.mkOutOfStoreSymlink wpaperd_path;
  home.file."Pictures/wallpaper/default".source =
    config.lib.file.mkOutOfStoreSymlink wallpaper_path;

  # set icon-theme
  gtk = {
    enable = true;
    theme = {
      package = pkgs.libsForQt5.breeze-gtk;
      name = "Breeze";
    };
    iconTheme = {
      package = pkgs.libsForQt5.breeze-icons;
      name = "breeze";
    };
  };
}
