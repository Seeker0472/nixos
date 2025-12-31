{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.seeker.home.wechat.enable = lib.mkEnableOption "Wechat";
  config = lib.mkMerge [
    (lib.mkIf config.seeker.home.wechat.enable {
      home.packages = [ pkgs.wechat ];
      wayland.windowManager.hyprland.settings = {
        windowrulev2 = [
          # WeChat 图片查看器
          "size 70% 70%, initialClass:^(wechat)$, initialTitle:^(预览)$"
          "float, initialClass:^(wechat)$, initialTitle:^(预览)$"

          "noborder, initialClass:^(wechat)$"
          "noshadow, initialClass:^(wechat)$"
          "noblur, initialClass:^(wechat)$"

          "workspace special:wechat, class:(wechat)"
        ];
        workspace = [
          "special:wechat, on-created-empty: [ ] QT_SCALE_FACTOR=1.6 wechat"
        ];
        bind = [ "$mainMod, W, togglespecialworkspace, wechat" ];
      };
    })
  ];
}
