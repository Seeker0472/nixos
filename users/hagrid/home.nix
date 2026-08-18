{ ... }:
{
  home.username = "hagrid";
  home.homeDirectory = "/home/hagrid";
  imports = [
    ../../modules/profiles/programs/home/bash.nix
    ../../modules/profiles/programs/home/tmux/default.nix
  ];
  home.stateVersion = "24.05";

  programs = {
    bash.enable = true;
    home-manager.enable = true;
    tmux.enable = true;
  };
}
