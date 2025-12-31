{ ... }:
{
  # git 相关配置
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "seeker";
        email = "gmx472@qq.com";
      };
      # 设置 kitten 为默认的 difftool
      diff.tool = "kitten";

      # 定义如何调用 kitten diff
      # 注意 Nix 字符串中需要转义内部的双引号
      difftool.kitten.cmd = ''kitten diff "$LOCAL" "$REMOTE"'';

      # 禁止 git difftool 在每次启动前都询问
      difftool.prompt = false;
    };
  };
}
