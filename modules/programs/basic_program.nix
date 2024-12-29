{ pkgs, nur, sharedConfig, ... }: {
  home.packages = with pkgs;[
    axel #Console app for parallel connection

    # networkmanagerapplet

  ] ++ (if sharedConfig.software_package == "cli" then [ ] else [

    # communication
    qq
    wechat-uos

    # multimedia
    vlc

    #utils
    xfce.thunar # file manager
    gparted
    clash-verge-rev

  ]);
  # home.packages = with pkgs; [
  # (pkgs.myApp.overrideAttrs (oldAttrs: {
  #   postInstall = ''
  #     wrapProgram $out/bin/myApp \
  #       --set MY_APP_VAR "app_value"
  #   '';
  # }))
  # ]

}
