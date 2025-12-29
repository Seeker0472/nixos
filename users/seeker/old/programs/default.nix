{
  pkgs,
  nur,
  ...
}: {
  imports = [./cli.nix ./gui.nix];
}
