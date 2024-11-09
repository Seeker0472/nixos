{ pkgs, nur, ... }: {
# 这里是目前我的DWM桌面的配套软件，将来等稳定以后把配置文件，shell移入
  home.packages = with pkgs;[
    # basic
    libinput # input driver
    xorg.xinit 
    dwm
    picom #animation
    i3lock-color #screen lock
    xss-lock #Use external locker (such as i3lock) as X screen saver

    # sys-util
    st #terminal
    lemonade #Remote utility tool that to copy, paste and open browsers over TCP
    dunst #notification daemon
    xdotool #tool in scripts
    acpi # battery status 
    xorg.xf86inputsynaptics
    libnotify

    # program
    # mpc-cli
    pavucontrol #audio control
    aider-chat ##ai
    brightnessctl
    networkmanager
    flameshot #screenshoot
    feh #Light-weight image viewer
    rofi 
    xfce.xfce4-power-manager #power-seeting

  ];
  home.file.".xinitrc".text = "exec dwm";

}
