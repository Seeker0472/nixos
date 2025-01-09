{ pkgs, nur, sharedConfig, ... }: {
  home.packages = with pkgs;[
    # productivity
    pandoc #文档
    ffmpeg
  ] ++ (if builtins.elem "gui" sharedConfig.software_package then [
    wpsoffice-cn
    obsidian
  ] else []) ++ (if builtins.elem "gui" sharedConfig.software_package then [
  # pkgs.nur.repos.linyinfeng.wemeet #腾讯会议
  pkgs.nur.repos.novel2430.wemeet-bin-bwrap-wayland-screenshare
  feishu
  drawio # 流程图
  gimp # 图片处理
  ] else [ ]);

}
