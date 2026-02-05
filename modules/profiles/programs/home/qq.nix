{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.seeker.home.qq.enable = lib.mkEnableOption "QQ";
  config = lib.mkMerge [
    (lib.mkIf config.seeker.home.qq.enable {
      home.packages = [ pkgs.qq ];
      wayland.windowManager.hyprland.settings = {
        windowrule = [
          "tag +qq_pic, match:initial_class ^(QQ)$, match:initial_title ^(图片查看器)$"
          "size (monitor_w*0.7) (monitor_h*0.7), match:tag qq_pic*"
          "float on, match:tag qq_pic*"
          "center on, match:tag qq_pic*"
          "workspace special:qq, match:class ^(QQ)$"
        ];
        workspace = [ "special:qq, on-created-empty: [ ] qq" ];
        bind = [
          "$mainMod, Q, togglespecialworkspace, qq"
          "$mainMod, 0, togglespecialworkspace, qq"
          # Fix for Linux QQ clipboard TODO
          "$mainMod CONTROL, C, exec, sh -c 'wl-paste --primary --no-newline | wl-copy'"
        ];
      };
    })
  ];
}
