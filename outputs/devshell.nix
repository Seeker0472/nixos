{ inputs, ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit.settings.hooks.nixfmt.enable = true;
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
