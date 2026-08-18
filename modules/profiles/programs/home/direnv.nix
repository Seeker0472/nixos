{
  config,
  lib,
  ...
}:
lib.mkIf config.programs.direnv.enable {
  programs.direnv = {
    nix-direnv.enable = true;
    config = {
      hide_env_diff = true;
    };
  };
}
