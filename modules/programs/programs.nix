{ pkgs, nur, ... }: {
  home.packages = with pkgs;[
    # programming/ysyx/learning
    
    jetbrains.idea-ultimate
    # jetbrains.clion
    # jetbrains.pycharm-professional
    fish
    kitty 
    gtkwave
    rocmPackages_5.llvm.clang-tools-extra #clangd
    # pkgs.nur.repos.lschuermann.vivado-2022_2
    ciscoPacketTracer8
    # communication
    qq
    wechat-uos
    #broswer
    google-chrome
    microsoft-edge
    # productivity
    wpsoffice-cn
    pkgs.nur.repos.linyinfeng.wemeet
    feishu
    obsidian
    drawio
    # pandoc
    # tectonic
    chromium

    # video
    obs-studio
    libsForQt5.kdenlive
    vlc
    #utils
    xfce.thunar
    gparted
    clash-verge-rev
    axel #Console app for parallel connection

    # networkmanagerapplet

  ];

}
