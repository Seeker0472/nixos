{
  config,
  lib,
  pkgs,
  nur,
  testargs,
  zen-browser,
  ...
}:
{
  config = lib.mkIf config.seeker.gui.enable {
    home.packages = with pkgs; [
      # ------ Develop ------
      gtkwave
      surfer # better wav

      # ------ Tools ------

      # Note: using sudo -EH gparted to start
      # Reference https://wiki.archlinux.org/title/Running_GUI_applications_as_root
      gparted
      # clash-verge-rev
      flclash

      # ------ multimedia ------
      mpv
      cava
      netease-cloud-music-gtk
      obs-studio
      # kdePackages.kdenlive
      viewnior # image viewer
      gimp3-with-plugins # 图片处理
      evince # pdf viewer

      # ------ games ------
      # hmcl

      # ------ broswer ------
      chromium

      # ------ Productity ------
      libreoffice
      obsidian
      # FIXME:maintain one myself
      # pkgs.nur.repos.novel2430.wemeet-bin-bwrap-wayland-screenshare
      drawio # 流程图
    ];
  };
}
