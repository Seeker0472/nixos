{
  config,
  lib,
  ...
}:
let
  cfg = config.seeker.de;
in
{
  config = lib.mkIf cfg.hyprland.enable {
    home-manager.sharedModules = [
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
  };
}
