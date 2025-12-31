{
  config,
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = [
    {
      wayland.windowManager.hyprland.settings = {
        exec-once = [
          "${pkgs.flclash}/bin/FlClash"
          "${pkgs.hypridle}/bin/hypridle" # idle management daemon (TODO screen-lock after wakeup)
          "fcitx5 --replace -d" # if run binary directly,pinyin cannot be activated
          "${pkgs.wpaperd}/bin/wpaperd"
          "systemctl --user start ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent" # polkit agent (root permission)
          "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
          "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
          # "docker ps" # 启动 docker 相关脚本
          # "libinput-gestures"
          # "ydotoold"
          "ksecretd"
        ]
        ++ lib.lists.optional config.seeker.de.waybar.enable "${pkgs.waybar}/bin/waybar";
      };
    }
  ];
}
