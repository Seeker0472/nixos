{ pkgs, nur, ... }: {
  home.packages = with pkgs;[
    # communication
    qq
    wechat-uos

    # multimedia
    vlc
    
    #utils
    xfce.thunar # file manager
    gparted
    clash-verge-rev
    axel #Console app for parallel connection

    # networkmanagerapplet

  ];
  # home.packages = with pkgs; [
  # (pkgs.myApp.overrideAttrs (oldAttrs: {
  #   postInstall = ''
  #     wrapProgram $out/bin/myApp \
  #       --set MY_APP_VAR "app_value"
  #   '';
  # }))
  # ]

}
