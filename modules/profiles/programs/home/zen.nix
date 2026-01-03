{ config, ... }:
{
  programs.zen-browser.enable = true;
  home.persistence."/persist/home/${config.home.username}".directories = [ ".zen" ];
}
