{ pkgs, ... }: {
  imports = [
    ./tools.nix
    ./bash.nix
    ./tmux
  ];
}
