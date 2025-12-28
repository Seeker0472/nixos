{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # 自定义变量
    "$terminal" = "kitty";
    "$fileManager" = "thunar";
    "$menu" = "wofi --show drun -a";

    # 环境变量
    env = [
      "QT_QPA_PLATFORM,wayland;xcb"
      "QT_IM_MODULE,fcitx"
      # "HYPRCURSOR_THEME,default"
      # "HYPRCURSOR_SIZE,24"
    ];


    # 如果你想启用之前注释掉的 monitor，可以取消下面的注释
    # monitor = [
    #   "eDP-1,2560x1600@120,0x0,1.3333333"
    #   "desc:Shenzhen KTC Technology Group H27V22 0x00000001,preferred,auto,auto"
    #   "desc:Dell Inc. DELL U2723QE JSGRL04,preferred,-2560x0,1.5"
    #   ",preferred,auto,auto"
    # ];

    xwayland = {
      force_zero_scaling = true;
    };
  };
}
