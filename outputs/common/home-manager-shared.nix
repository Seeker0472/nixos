{ inputs }:
let
  lib = inputs.nixpkgs.lib;
  commonModules = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.zen-browser.homeModules.beta
    inputs.nixvim.homeModules.nixvim
    inputs.aloha.homeManagerModules.default
    ../../modules/home
  ];
  standaloneOnlyModules = [
    "${inputs.impermanence}/home-manager.nix"
    {
      home._nixosModuleImported = true;
    }
  ];
in
{
  extraSpecialArgs = {
    inherit inputs;
  };

  mkModuleList =
    {
      standalone ? false,
      extraModules ? [ ],
    }:
    commonModules ++ lib.optionals standalone standaloneOnlyModules ++ extraModules;
}
