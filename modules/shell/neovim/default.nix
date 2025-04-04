{ pkgs, ... }: {
  imports = [
    # ./nvim.nix
    ./map.nix
  ];
  programs.neovim.enable = true;
  home.packages = with pkgs; [
    # xclip
    # clipman
    wl-clipboard
    lua5_1
    luarocks
    ripgrep
  ];
}
