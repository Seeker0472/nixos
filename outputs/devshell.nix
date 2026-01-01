{ inputs, ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          vim
          neovim
          nixfmt-rfc-style
          sops
          age
        ];
      };
    };
}
