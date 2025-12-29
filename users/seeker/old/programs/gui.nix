{
  pkgs,
  nur,
  testargs,
  zen-browser,
  ...
}: {
  programs.zen-browser.enable = true;
  home.packages = with pkgs; [
    # ------ Develop ------
    vscode
    zed-editor
    gtkwave
    surfer # better wav

    # ------ Tools ------

    xfce.thunar # file manager
    xfce.xfconf # save preface for thunar
    # Note: using sudo -EH gparted to start
    # Reference https://wiki.archlinux.org/title/Running_GUI_applications_as_root
    gparted
    # clash-verge-rev
    flclash

    # ------ communication ------
    qq
    wechat
    # wechat-uos

    # ------ multimedia ------
    mpv
    cava
    netease-cloud-music-gtk
    obs-studio
    kdePackages.kdenlive
    viewnior # image viewer
    gimp3-with-plugins # 图片处理
    evince # pdf viewer

    # ------ games ------
    hmcl

    # ------ broswer ------
    google-chrome
    #    microsoft-edge
    chromium

    # ------ Productity ------
    # weird !,adding wpsoffice will cause doc to it's default application nomatter what mime app set
    # wpsoffice-cn
    libreoffice
    obsidian
    # pkgs.nur.repos.linyinfeng.wemeet #腾讯会议
    # FIXME:maintain one myself
    # pkgs.nur.repos.novel2430.wemeet-bin-bwrap-wayland-screenshare
    # feishu
    drawio # 流程图
    zotero
  ];
}
