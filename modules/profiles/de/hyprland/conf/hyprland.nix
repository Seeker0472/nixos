{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  hyprlandEnabled = lib.attrByPath [
    "machine"
    "de"
    "hyprland"
    "enable"
  ] false osConfig;
in
{
  config = lib.mkIf hyprlandEnabled {
    home.packages = [ pkgs.nwg-displays ]; # set display for hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      systemd.enable = true;
      extraConfig = ''
        # source the nwg-displays generated config
        source = ./monitors.conf
      '';
      settings = {
        "$menu" = "wofi --show drun -a";

        env = [
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_IM_MODULE,fcitx"
          # "HYPRCURSOR_THEME,default"
          # "HYPRCURSOR_SIZE,24"
        ];

        xwayland = {
          force_zero_scaling = true;
        };
      };
    };
  };
}
