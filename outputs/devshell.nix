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
      packages = lib.optionalAttrs (system == "x86_64-linux") {
        devContainerImage =
          let
            imagePkgs = import inputs.nixpkgs (
              {
                inherit system;
              }
              // (import ./common/nixpkgs-config.nix { inherit inputs; })
            );
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
