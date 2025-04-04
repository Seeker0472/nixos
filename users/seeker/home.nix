{ pkgs, ... }: {
  ####################################################
  #
  #   All Seeker's Home Manager Conf.
  #
  ####################################################

  # 用户名与用户目录
  home.username = "seeker";
  home.homeDirectory = "/home/seeker";

  imports = [
    # pkgs.anyrun.homeManagerModules.default  
    ../../modules/programs
    ../../modules/shell
    ../../modules/gui
    # ../../modules/input
    ../../modules/input
    ./basepkgs.nix
    ./xdg_default.nix
  ];

  # git 相关配置
  programs.git = {
    enable = true;
    userName = "seeker";
    userEmail = "gmx472@qq.com";
    extraConfig = {
      # 设置 kitten 为默认的 difftool
      diff.tool = "kitten";

      # 定义如何调用 kitten diff
      # 注意 Nix 字符串中需要转义内部的双引号
      difftool.kitten.cmd = ''kitten diff "$LOCAL" "$REMOTE"'';

      # 禁止 git difftool 在每次启动前都询问
      difftool.prompt = false;
    };
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
