{
  config,
  lib,
  ...
}:
{
  ####################################################
  #
  #   All Seeker's Home Manager Conf.
  #
  ####################################################

  # 用户名与用户目录
  home = {
    username = lib.mkDefault "seeker";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    stateVersion = "24.05";
  };

  imports = [
    ../../modules/home/base.nix
    ./tools.nix
    ./git.nix
    ./config.nix
    ./ssh.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
