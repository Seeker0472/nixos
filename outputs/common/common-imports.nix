{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModule
    inputs.home-manager.nixosModules.home-manager
    inputs.nixvim.nixosModules.nixvim
  ];
  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.zen-browser.homeModules.beta
    inputs.nixvim.homeModules.nixvim
    # inputs.impermanence.homeManagerModules.impermanence
  ];
}
