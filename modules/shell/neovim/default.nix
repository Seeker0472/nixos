{ pkgs, ... }: {
  imports = [
    # ./nvim.nix
  ];
  programs.neovim.enable=true;
}
