###################################################################
#  desktop environment configuration
###################################################################

{ config, lib, pkgs, modulesPath, ... }:

{

  services = {
    xserver = {
      enable = true;
      windowManager.dwm.enable = true;
      dpi = 144; # DPI,
      upscaleDefaultCursor = true;
      # displayManager.sessionCommands =
      #   ''
      #     ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1  --scale 1x1  \
      #                                         --output DP-1 --auto  --scale 1.5x1.5 --right-of eDP-1   \
      #                                         --output DP-2 --auto --scale 1.5x1.5 --right-of eDP-1  
      #   '';
      #xrandr --output eDP-1  --scale 1x1 --output DP-1 --auto  --scale 1.5x1.5 --right-of eDP-1 -output DP-2 --auto --scale 1.5x1.5 --right-of eDP-1
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };
      displayManager.lightdm.enable = true;
      displayManager.lightdm.greeters.gtk.cursorTheme = {
        package = pkgs.kdePackages.breeze;
        name = "Breeze";
        size = 44;
      };
      # deviceSection = ''
      #    Identifier  "Intel Graphics"
      #     Driver      "intel"
      # ''
      # videoDrivers = ["intel"];
    };

    displayManager = {
      # lightdm.enable = true;
      defaultSession = "none+dwm";
    };
    # displayManager.sddm.enable = true;
    # displayManager.sddm.wayland.enable = true;

  };
  # dconf is a low-level configuration system and settings management tool
  programs.dconf.enable = true;
  # services.desktopManager.plasma6.enable = true;

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    # QT_SCALE_FACTOR = "2";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
    XCURSOR_SIZE = "44";
    XCURSOR_THEME = "Breeze";
  };

  # Hyperland
  #   programs.hyprland = {
  #     enable = true;
  #     xwayland.enable = true;
  #   };
  #   environment.systemPackages = with pkgs; [
  #     kitty
  #   ];

}
