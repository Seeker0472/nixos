{ pkgs, ... }:
{
  home.packages =
    (import ./packages/base.nix { inherit pkgs; }) ++ (import ./packages/dev.nix { inherit pkgs; });
}
