{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.machine.home.wechat.enable = lib.mkEnableOption "Wechat";
  config = lib.mkMerge [
    (lib.mkIf config.machine.home.wechat.enable {
      home.packages = [ pkgs.wechat ];
      wayland.windowManager.hyprland.settings = {
        windowrule = [
          # WeChat 图片查看器
          "tag +wechat_pic,match:initial_class ^(wechat)$, match:initial_title ^(预览)$"
          "size (monitor_w*0.7) (monitor_h*0.7), match:tag wechat_pic*"
          "float on, match:tag wechat_pic*"
          "center on, match:tag wechat_pic*"

          "tag +wechat,match:initial_class ^(wechat)$"

          "border_size 0, match:tag wechat*"
          "no_shadow on, match:tag wechat*"
          "no_blur on, match:tag wechat*"

          "workspace special:wechat, match:tag wechat*"
        ];
        workspace = [
          "special:wechat, on-created-empty: [ ] QT_SCALE_FACTOR=1.6 wechat"
        ];
        bind = [ "$mainMod, W, togglespecialworkspace, wechat" ];
      };
    })
  ];
}
