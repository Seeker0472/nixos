{ pkgs, nur, sharedConfig, ... }: {
  home.packages = with pkgs;
    [
      # productivity

      pandoc # 文档
      ffmpeg
      marp-cli
    ] ++ (if builtins.elem "gui" sharedConfig.software_package then [
      evince # pdf viewer
      # weird !,adding wpsoffice will cause doc to it's default application nomatter what mime app set
      # wpsoffice-cn
      libreoffice
      obsidian
    ] else
      [ ]) ++ (if builtins.elem "gui" sharedConfig.software_package then [
        # pkgs.nur.repos.linyinfeng.wemeet #腾讯会议
        pkgs.nur.repos.novel2430.wemeet-bin-bwrap-wayland-screenshare
        # feishu
        drawio # 流程图
        gimp3-with-plugins # 图片处理
      ] else
        [ ]);

}
