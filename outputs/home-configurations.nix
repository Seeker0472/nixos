{ inputs, ... }:
let
  system = "x86_64-linux";
  nixpkgsConfig = import ./common/nixpkgs-config.nix { inherit inputs; };
  pkgs = import inputs.nixpkgs (
    {
      inherit system;
    }
    // nixpkgsConfig
  );
in
{
  flake.homeConfigurations."seeker4721@gpu01" = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs; };
    modules = [
      inputs.nixvim.homeModules.nixvim
      inputs.sops-nix.homeManagerModules.sops
      ../modules/profiles/programs/nixvim/default.nix
      ../users/seeker/home.nix
      ../hosts/gpu01/home.nix
    ];
  };
}
