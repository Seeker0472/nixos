{
  config,
  lib,
  ...
}:
let
  cfg = config.machine.de;
in
{
  home-manager.sharedModules = lib.optionals cfg.hyprland.enable [
    {
      xdg.configFile = {
        "wofi".source = lib.mkIf cfg.wofi.enable ./wofi;
        "mako".source = lib.mkIf cfg.mako.enable ./mako;
        "wpaperd".source = lib.mkIf cfg.wpaperd.enable ./wpaperd;
      };

      home.file = {
        "Pictures/wallpaper/default".source = ./wallpaper;
      };
    }
  ];
}
