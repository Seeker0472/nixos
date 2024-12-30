{ pkgs, sharedConfig, ... }: {
  imports = [
    ./tools.nix
    ./bash.nix
    ./fish.nix
    ./tmux
    ./neovim
  ]++ (if builtins.elem "gui" sharedConfig.software_package then [
    ./kitty.nix
  ] else []);
}
