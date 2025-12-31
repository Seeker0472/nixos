{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.seeker.home.thunar.enable = lib.mkEnableOption "Thunar";
  config = lib.mkMerge [
    (lib.mkIf config.seeker.home.thunar.enable {
      home.packages = [
        pkgs.xfce.thunar
        pkgs.xfce.xfconf
      ];
      wayland.windowManager.hyprland.settings = {
        "$fileManager" = "thunar";
        windowrulev2 = [
          # Thunar Float
          "size 50% 20%, initialClass:^(Thunar)$,initialTitle:^(File Operation Progress)$"
          "size 50% 50%, initialClass:^(Thunar)$,initialTitle:(.*Properties)"
          "size 70% 70%, initialClass:^(Thunar)$"
          "float, initialClass:^(Thunar)$"
        ];
        bind = [
          "$mainMod, E, exec, $fileManager"
        ];
      };
    })
  ];
}
