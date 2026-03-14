{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.machine.programs.thunar.enable = lib.mkEnableOption "Thunar";

  config = lib.mkIf config.machine.programs.thunar.enable {
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
          windowrule = [
            "tag +thunar, match:class (thunar)"
            "float on, match:tag thunar*"
            "center on, match:tag thunar*"
            "size (monitor_w*0.7) (monitor_h*0.7), match:tag thunar*"
            "size (monitor_w*0.5) (monitor_h*0.5), match:tag thunar*,match:title ^(File Operation Progress)$"
            "size (monitor_w*0.5) (monitor_h*0.5), match:tag thunar*,match:title (.*Properties)"
          ];
          bind = [
            "$mainMod, E, exec, $fileManager"
          ];
        };
      }
    ];
  };
}
