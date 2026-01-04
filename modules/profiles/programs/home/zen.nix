{ config, osConfig, ... }:
{
  programs.zen-browser.enable = true;
  home.persistence."${osConfig.seeker.btrfs.impermanence.persistdir}/home/${config.home.username}".directories =
    [ ".zen" ];
}
