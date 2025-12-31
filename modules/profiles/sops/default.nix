{ config, ... }:
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        sops.age.keyFile = "${config.xdg.configHome}/age/keys";
        systemd.user.services.mbsync.unitConfig.After = [ "sops-nix.service" ];
      }
    )
  ];
}
