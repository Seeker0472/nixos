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
        windowrulev2 = [
          "size 70% 70%, initialClass:^(QQ)$, initialTitle:^(图片查看器)$"
          "float, initialClass:^(QQ)$, initialTitle:^(图片查看器)$"
          "workspace special:qq, class:(QQ)"
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
