{ pkgs, nur, ... }: {
# 这里是目前我的DWM桌面的配套软件，将来等稳定以后把配置文件，shell移入
  home.packages = with pkgs;[
    libinput
    xorg.xinit
    dwm
    st

    feh
    lemonade
    flameshot
    dunst
    picom
    xdotool

    i3lock-color

    acpi

    xorg.xf86inputsynaptics
    xss-lock
    mpc-cli

    rofi
    libnotify
    
    networkmanager

  ];

}
