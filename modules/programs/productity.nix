{ pkgs, nur, ... }: {
  home.packages = with pkgs;[
    # productivity
    pkgs.nur.repos.linyinfeng.wemeet #腾讯会议
    feishu 
    drawio # 流程图
    gimp # 图片处理
    ffmpeg
  ];
}