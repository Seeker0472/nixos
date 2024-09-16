{pkgs, ...}:{
    ####################################################
    #
    #   All Seeker's Home Manager Conf.
    #
    ####################################################

    # 用户名与用户目录
    home.username = "seeker";
    home.homeDirectory = "/home/seeker";

    imports =[
      # pkgs.anyrun.homeManagerModules.default  
      ../../modules/programs
      ../../modules/shell
      ../../modules/gui
      # ../../modules/input
      ./basepkgs.nix
    ];

  # git 相关配置
  programs.git = {
    enable = true;
    userName = "seeker";
    userEmail = "gmx472@qq.com";
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