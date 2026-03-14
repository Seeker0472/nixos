{
  config,
  osConfig,
  pkgs,
  ...
}:
let
  flakeTarget = "${config.home.username}@${osConfig.networking.hostName}";
in
{
  home.username = "hagrid";
  home.homeDirectory = "/home/hagrid";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

}
