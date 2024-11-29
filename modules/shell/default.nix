{ pkgs, ... }: {
  imports = [
    ./tools.nix
    ./bash.nix
    ./fish.nix
    ./kitty.nix
    ./tmux
    ./neovim
  ];
}
