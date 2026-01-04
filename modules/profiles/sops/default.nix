{ config, ... }:
{
  home-manager.sharedModules = [
    (
      { config, osConfig, ... }:
      {
        sops.age.keyFile = osConfig.seeker.secrets.ageKeyPath;
        systemd.user.services.mbsync.unitConfig.After = [ "sops-nix.service" ];
      }
    )
  ];
}
