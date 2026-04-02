{
  lib,
  osConfig,
  ...
}:
let
  cfg = lib.attrByPath [
    "machine"
    "de"
  ] { } osConfig;
in
{
  config = lib.mkIf (cfg.hyprland.enable or false) {
    xdg.configFile = {
      "wofi".source = lib.mkIf (cfg.wofi.enable or false) ./wofi;
      "mako".source = lib.mkIf (cfg.mako.enable or false) ./mako;
      "wpaperd".source = lib.mkIf (cfg.wpaperd.enable or false) ./wpaperd;
    };

    home.file."Pictures/wallpaper/default".source = ./wallpaper;
  };
}
