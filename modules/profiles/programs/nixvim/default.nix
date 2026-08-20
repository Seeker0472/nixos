{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.machine.programs.nixvim;
in
{
  options.machine.programs.nixvim.development.enable =
    lib.mkEnableOption "the full Neovim development environment";

  config.programs.nixvim = {
    defaultEditor = lib.mkIf cfg.development.enable true;
    enable = true;
    nixpkgs.source = inputs.nixpkgs;
    viAlias = lib.mkIf cfg.development.enable true;
    vimAlias = lib.mkIf cfg.development.enable true;
    imports = [ ./config/default.nix ] ++ lib.optional cfg.development.enable ./config/development.nix;
  };
}
