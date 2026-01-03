{ config, ... }:
{
  programs.zen-browser.enable = true;
  home.persistence."${config.seeker.btrfs.impermanence.persistdir}/home/${config.home.username}".directories =
    [ ".zen" ];
}
