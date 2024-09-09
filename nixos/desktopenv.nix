###################################################################
#  desktop environment configuration
###################################################################

{ config, lib, pkgs, modulesPath, ... }:

{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.xserver.dpi = 120; # 根据实际情况调整数值

  # Hyperland
  #   programs.hyprland = {
  #     enable = true;
  #     xwayland.enable = true;
  #   };
  #   environment.systemPackages = with pkgs; [
  #     kitty
  #   ];



}



