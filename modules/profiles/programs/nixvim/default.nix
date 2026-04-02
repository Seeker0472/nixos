{ ... }:
{
  programs.nixvim = {
    enable = true;
    imports = [
      ./config/default.nix
    ];
  };
}
