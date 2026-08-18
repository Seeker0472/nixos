{ inputs, ... }:
{
  programs.nixvim = {
    enable = true;
    nixpkgs.source = inputs.nixpkgs;
    imports = [
      ./config/default.nix
    ];
  };
}
