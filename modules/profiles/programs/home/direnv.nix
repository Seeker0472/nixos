{
  config,
  osConfig,
  lib,
  ...
}:
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
  home.persistence."${osConfig.seeker.btrfs.impermanence.persistdir}/home/${config.home.username}".directories =
    [
      ".local/share/direnv"
    ];
}
