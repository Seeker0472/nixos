{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
in
{
  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      pre-commit.settings.hooks.nixfmt.enable = true;
      formatter = pkgs.nixfmt-tree;
      packages = lib.optionalAttrs (system == "x86_64-linux") {
        devContainerImage =
          let
            imagePkgs = import ./common/mk-pkgs.nix { inherit inputs system; };
          in
          import ./dev-container-image.nix {
            inherit inputs;
            pkgs = imagePkgs;
          };
      };
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          vim
          neovim
          nixfmt
          sops
          age
        ];
        shellHook = "${config.pre-commit.shellHook}";
      };
    };
}
