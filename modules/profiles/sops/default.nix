{ config, ... }:
{
  home-manager.sharedModules = [
    (
      { lib, osConfig, ... }:
      let
        ageKeyPath = lib.attrByPath [
          "machine"
          "secrets"
          "ageKeyPath"
        ] null osConfig;
      in
      lib.optionalAttrs (ageKeyPath != null) {
        sops.age.keyFile = ageKeyPath;
        systemd.user.services.mbsync.unitConfig.After = [ "sops-nix.service" ];
      }
    )
  ];
}
