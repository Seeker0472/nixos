{ config, lib, ... }:
{
  programs.direnv = {
    # enable = true;
    # enableBashIntegration =true;
    # enableFishIntegration = true;
    nix-direnv.enable = true;
    config = {
      hide_env_diff = true;
    };
  };
}
