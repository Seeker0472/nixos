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
  options.machine.programs.nixvim = {
    enable = lib.mkEnableOption "Nixvim";
    development.enable = lib.mkEnableOption "the full Neovim development environment";
  };

  config = lib.mkIf (cfg.enable || cfg.development.enable) {
    programs.nixvim = {
      enable = true;
      defaultEditor = lib.mkDefault cfg.development.enable;
      nixpkgs.source = inputs.nixpkgs;
      viAlias = lib.mkDefault cfg.development.enable;
      vimAlias = lib.mkDefault cfg.development.enable;
      imports = [ ./config/default.nix ] ++ lib.optional cfg.development.enable ./config/development.nix;
    };
  };
}
