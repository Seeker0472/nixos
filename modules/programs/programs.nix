{ pkgs, nur, ... }: {
  home.packages = with pkgs;[
    # programming/ysyx/learning
    
    jetbrains.idea-ultimate
    # jetbrains.clion
    # jetbrains.pycharm-professional
    gcc
    gdb
    gnumake
    lazygit

    gtkwave
    surfer # better wave
    rocmPackages_5.llvm.clang-tools-extra #clangd
    # pkgs.nur.repos.lschuermann.vivado-2022_2
    ciscoPacketTracer8

    # communication
    qq
    wechat-uos

    #broswer
    google-chrome
    microsoft-edge
    chromium

    # productivity
    wpsoffice-cn
    pkgs.nur.repos.linyinfeng.wemeet #腾讯会议
    feishu 
    obsidian
    drawio # 流程图
    gimp # 图片处理
    ffmpeg
    pandoc #文档

    # video
    obs-studio
    libsForQt5.kdenlive
    vlc
    
    #utils
    xfce.thunar # file manager
    gparted
    clash-verge-rev
    axel #Console app for parallel connection

    # networkmanagerapplet

  ];

}
