{ pkgs, nur, sharedConfig, ... }: {
  home.packages = with pkgs;
    [
      axel # Console app for parallel connection
      # clipboard
      wl-clip-persist
      wl-clipboard
      cliphist
      # networkmanagerapplet
    ] ++ (if builtins.elem "gui" sharedConfig.software_package then [
      # communication
      qq
      wechat-uos

      # multimedia
      # vlc
      mpv
      cava
      netease-cloud-music-gtk
      viewnior # image viewer

      #utils
      xfce.thunar # file manager
      xfce.xfconf # save preface for thunar

      # Note: using sudo -EH gparted to start
      # Reference https://wiki.archlinux.org/title/Running_GUI_applications_as_root
      gparted

      clash-verge-rev
      ncdu
      # games
      hmcl
    ] else
      [ ])
    ++ (if builtins.elem "tools_full" sharedConfig.software_package then [
      obs-studio
      kdePackages.kdenlive
    ] else
      [ ]);
  # home.packages = with pkgs; [
  # (pkgs.myApp.overrideAttrs (oldAttrs: {
  #   postInstall = ''
  #     wrapProgram $out/bin/myApp \
  #       --set MY_APP_VAR "app_value"
  #   '';
  # }))
  # ]

}
