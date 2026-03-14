{ inputs, ... }:
{
  nixpkgs = import ./nixpkgs-config.nix { inherit inputs; };
}
