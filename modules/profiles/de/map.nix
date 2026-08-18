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
    xdg.configFile = lib.mkMerge [
      (lib.mkIf (cfg.wofi.enable or false) {
        "wofi".source = ./wofi;
      })
      (lib.mkIf (cfg.mako.enable or false) {
        "mako".source = ./mako;
      })
      (lib.mkIf (cfg.wpaperd.enable or false) {
        "wpaperd".source = ./wpaperd;
      })
    ];

    home.file."Pictures/wallpaper/default".source = ./wallpaper;
  };
}
