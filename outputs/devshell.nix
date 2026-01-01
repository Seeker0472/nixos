{ inputs, ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit.settings.hooks.nixfmt-rfc-style.enable = true;
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          vim
          neovim
          nixfmt-rfc-style
          sops
          age
        ];
        shellHook = ''${config.pre-commit.shellHook}'';
      };
    };
}
