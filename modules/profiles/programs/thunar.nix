{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.seeker.programs.thunar.enable = lib.mkEnableOption "Thunar";

  config = lib.mkIf config.seeker.programs.thunar.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    programs.xfconf.enable = true;

    services.gvfs.enable = true;
    services.tumbler.enable = true; # 缩略图服务

    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland.settings = {
          "$fileManager" = "thunar";
          windowrulev2 = [
            "float, class:^(thunar)$"
            "size 70% 70%, class:^(thunar)$"
            "size 50% 20%, class:^(thunar)$,title:^(File Operation Progress)$"
            "size 50% 50%, class:^(thunar)$,title:(.*Properties)"
          ];
          bind = [
            "$mainMod, E, exec, $fileManager"
          ];
        };
      }
    ];
  };
}
