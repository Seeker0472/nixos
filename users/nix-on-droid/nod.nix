{ pkgs, lib, ... }: {
  imports = [
    # pkgs.anyrun.homeManagerModules.default  
    ../../modules/programs
    ../../modules/shell
    ../../modules/gui
  ];

  # git 相关配置
  programs.git = {
    enable = true;
    userName = "seeker";
    userEmail = "gmx472@qq.com";
  };
  programs.bash.bashrcExtra = ''
    exec fish
  '';

  home.stateVersion = "24.05";

    # ${pkgs.coreutils}/bin/cp -f ${pkgs.maple-mono.NF-CN}/share/fonts/truetype/MapleMono-NF-CN-Regular.ttf ${config.home.homeDirectory}/.termux/font.ttf
  home.activation.copyFont = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.termux"
    ${pkgs.coreutils}/bin/rm -f "$HOME/.termux/font.ttf"
    ${pkgs.coreutils}/bin/cp -f ${pkgs.maple-mono-NF}/share/fonts/truetype/MapleMono-NF-Regular.ttf $HOME/.termux/font.ttf
'';
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
