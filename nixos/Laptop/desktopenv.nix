###################################################################
#  desktop environment configuration
###################################################################

{ config, lib, pkgs, modulesPath, ... }:

{

  services = {
    xserver = {
      enable = true;
      windowManager.dwm.enable = true;
      libinput.enable = true;
      dpi = 144; # DPI,
      upscaleDefaultCursor = true;
      displayManager.sessionCommands =
        ''
          ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1  --scale 1x1  \
                                              --output DP-1 --auto  --scale 1.5x1.5   \
                                              --output DP-2 --auto --scale 1.5x1.5   
        '';
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };

  # services.desktopManager.plasma6.enable = true;

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
    XCURSOR_SIZE = "144";
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



