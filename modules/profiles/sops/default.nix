{
  lib,
  osConfig,
  ...
}:
{
  config =
    let
      deploySecrets = lib.attrByPath [
        "machine"
        "secrets"
        "deploy"
      ] true osConfig;
      ageKeyPath = lib.attrByPath [
        "machine"
        "secrets"
        "ageKeyPath"
      ] null osConfig;
    in
    lib.optionalAttrs (deploySecrets && ageKeyPath != null) {
      sops.age.keyFile = ageKeyPath;
      systemd.user.services.mbsync.unitConfig.After = [ "sops-nix.service" ];
    };
}
