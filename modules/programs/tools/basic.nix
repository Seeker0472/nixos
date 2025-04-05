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
      vlc
      mpv

      #utils
      xfce.thunar # file manager
      xfce.xfconf # save preface for thunar

      gparted
      clash-verge-rev
      ncdu
      # games
      hmcl
    ] else
      [ ])
    ++ (if builtins.elem "tools_full" sharedConfig.software_package then [
      obs-studio
      libsForQt5.kdenlive
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
